//
//  TCLocationService.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCLocationService.h"
#import "RACSignal+TCOperatorAdditions.h"

@interface TCLocationService ()

@property (nonatomic, strong, readonly) CLLocationManager *locationManager;
@property (nonatomic, assign, readonly) NSTimeInterval maxLocationAge;

@end

@implementation TCLocationService

#pragma mark Public Methods

- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager
                         maxLocationAge:(NSTimeInterval)maxLocationAge
{
    NSParameterAssert(locationManager != nil);
    NSParameterAssert(maxLocationAge > 0);

    NSAssert(nil == locationManager.delegate, @"Do NOT set a delegate for `locationManager`. Location service should be the delegate for `locationManager`.");

    self = [super init];
    if (!self) { return nil; }

    _locationManager = locationManager;
    _maxLocationAge = maxLocationAge;

    _locationManager.delegate = self;

    return self;
}

- (RACSignal *)currentLocation
{
    __block NSUInteger subscriberCount = 0;

    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @synchronized(self) {
            // If this is the first subscriber to this signal, start the
            // location updates.
            if (++subscriberCount == 1) {
                NSLog(@"Location Services Started");
                [self.locationManager startUpdatingLocation];
            }
        }

        // We need to replay the last location value to later
        // subscribers. Otherwise, later subscribers may miss the
        // location update event.
        [[[self locationUpdate]
          tc_replayLastLazily]
          subscribe:subscriber];

        return [RACDisposable disposableWithBlock:^{
            @synchronized(self) {
                // If we have no more subscribers, we will stop the
                // location updates. It will be restarted again, when
                // this signal has new subscribers.
                if (--subscriberCount == 0) {
                    NSLog(@"Location Services Stopped");
                    [self.locationManager stopUpdatingLocation];
                }
            }
        }];
    }] setNameWithFormat:@"%@ -currentLocation", self];
}

- (RACSignal *)isAuthorized
{
    // Returns the current authorization status value and
    // concatenates subsequent values delivered to the delegate.
    return [[[[RACSignal return:@(CLLocationManager.authorizationStatus)]
             concat:[self valueForCLLocationManagerDelegateSelector:
                     @selector(locationManager:didChangeAuthorizationStatus:)]]
             map:^(NSNumber *authorizationStatus) {
                 CLAuthorizationStatus status = authorizationStatus.unsignedIntegerValue;

                 // YES if we're authorized to use location service; NO otherwise.
                 return @(status == kCLAuthorizationStatusAuthorized ||
                          status == kCLAuthorizationStatusNotDetermined);
             }]
             setNameWithFormat:@"%@ -isAuthorized", self];
}

#pragma mark Private Methods

/**
 * Returns @c YES if @c location matches the given accuracy and age; 
 * @c NO otherwise.
 */
- (BOOL)isAcceptableLocation:(CLLocation *)location
                withAccuracy:(CLLocationAccuracy)desiredAccuracy
                   andMaxAge:(NSTimeInterval)maxAge
{
    // `nil` is definitely unacceptable!
    if (nil == location) { return NO; }

    // Location data can be returned from the cache. Make sure that
    // location data is not too old. Otherwise, we will be using
    // stale location data.
    NSTimeInterval locationAge = fabs([location.timestamp timeIntervalSinceNow]);
    BOOL isRecentEnough = (locationAge <= maxAge);

    // A negative value for the `horizontalAccuracy` indicates that
    // the location’s latitude and longitude are invalid.
    // CLLocationManager `desiredAccuracy` is negative if it is
    // `kCLLocationAccuracyBestForNavigation` or `kCLLocationAccuracyBest`.
    BOOL isAccurateEnough = (location.horizontalAccuracy >= 0 &&
                             location.horizontalAccuracy <= MAX(desiredAccuracy, 0));

    return isRecentEnough && isAccurateEnough;
}

/**
 * Signal of location values sent by location services when
 * it has started.
 *
 * This signal terminates with an error event if  @c 
 * locationManager:didFailWithError: is called.
 */
- (RACSignal *)locationUpdate
{
    return [[[[[[self rac_signalForSelector:@selector(locationManager:didUpdateLocations:)
                               fromProtocol:@protocol(CLLocationManagerDelegate)]
        map:^(RACTuple *locationManagerAndLocationArray) {
            RACTupleUnpack(CLLocationManager *locationManager,
                           NSArray *locations) = locationManagerAndLocationArray;

            // Get the most recent location data, which is at the end of
            // the array.
            return RACTuplePack(locationManager, locations.lastObject);
        }]
        filter:^BOOL(RACTuple *locationManagerAndLatestLocation) {
            RACTupleUnpack(CLLocationManager *locationManager,
                           CLLocation *location) = locationManagerAndLatestLocation;

            return [self isAcceptableLocation:location
                                 withAccuracy:locationManager.desiredAccuracy
                                    andMaxAge:self.maxLocationAge];
        }]
        map:^(RACTuple *locationManagerAndLatestLocation) {
            // We just want the latest location value.
            return locationManagerAndLatestLocation[1];
        }]
        // Location updates signal does not include any error events.
        // Merge it with the error signal to get the error events.
        merge:self.locationError]
        setNameWithFormat:@"%@ -locationUpdate", self];
}

/**
 * Signal that sends an error event when location services failed to
 * retrieve a location value.
 */
- (RACSignal *)locationError
{
    return [[[[self valueForCLLocationManagerDelegateSelector:
               @selector(locationManager:didFailWithError:)]
            filter:^BOOL(NSError *error) {
                // If the location service is unable to retrieve a location
                // right away, it reports a kCLErrorLocationUnknown error and
                // keeps trying. In such a situation, you can simply ignore the
                // error and wait for a new event.
                return !(error.domain == kCLErrorDomain &&
                         error.code == kCLErrorLocationUnknown);
            }]
            flattenMap:^(NSError *error) {
                // Terminate this signal with an error event.
                return [RACSignal error:error];
            }]
            setNameWithFormat:@"%@ -locationError", self];
}

/**
 * Returns the second argument of the CLLocationManagerDelegate methods.
 *
 * The first argument is the CLLocationManager instance that we ignore.
 * The second argument is the value that we want.
 */
- (RACSignal *)valueForCLLocationManagerDelegateSelector:(SEL)selector
{
    return [[self rac_signalForSelector:selector
                          fromProtocol:@protocol(CLLocationManagerDelegate)]
            map:^(RACTuple *args) {
                // The use of args.second will be deprecated in RAC 3.0,
                // so we use subscripting instead.
                return args[1];
            }];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {}

@end

