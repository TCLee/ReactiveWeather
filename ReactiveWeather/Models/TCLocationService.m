//
//  TCLocationService.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

#import "TCLocationService.h"

@interface RACSignal (TCOperatorAdditions)

- (RACSignal *)replayLastLazily;

@end

@implementation RACSignal (TCOperatorAdditions)

- (RACSignal *)replayLastLazily
{
    RACMulticastConnection *connection =
        [self multicast:[RACReplaySubject replaySubjectWithCapacity:1]];

    return [[RACSignal
             defer:^{
                 [connection connect];
                 return connection.signal;
             }]
             setNameWithFormat:@"[%@] -replayLastLazily", self.name];
}

@end

/**
 * Cached location data that is older than this maximum limit will be
 * discarded. The age is calculated in seconds.
 */
static const NSTimeInterval TCMaxAcceptableLocationAge = 15.0f;

// Privately adopt the CLLocationManagerDelegate protocol.
@interface TCLocationService () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation TCLocationService

#pragma mark Public Methods

- (instancetype)init
{
    self = [super init];
    if (!self) { return nil; }

    _locationManager = [[CLLocationManager alloc] init];

    // Since we're getting the weather forecast for a city, we do not
    // need very accurate location data.
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    _locationManager.distanceFilter = 1000;

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

        [[self locationUpdatesSignal] subscribe:subscriber];

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
                     @selector(locationManager:didUpdateLocations:)]]
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
 * Signal of location updates sent by location services when it has started.
 *
 * This signal terminates with an error event if 
 * @c locationManager:didFailWithError: is called.
 */
- (RACSignal *)locationUpdatesSignal
{
    RACSignal *locationUpdates =
        [[[[self valueForCLLocationManagerDelegateSelector:
            @selector(locationManager:didUpdateLocations:)]
         map:^(NSArray *locations) {
             // Get the most recent location data, which is at the end of the array.
             return locations.lastObject;
         }]
         filter:^BOOL(CLLocation *location) {
             // Location data can be returned from the cache. Make sure that
             // location data is not too old. Otherwise, we will be using
             // stale location data.
             NSTimeInterval locationAge = fabs([location.timestamp timeIntervalSinceNow]);
             return locationAge <= TCMaxAcceptableLocationAge;
         }]
         filter:^BOOL(CLLocation *location) {
             // A negative value for the horizontalAccuracy indicates that
             // the location’s latitude and longitude are invalid.
             return (location.horizontalAccuracy > 0 &&
                     location.horizontalAccuracy <= kCLLocationAccuracyKilometer);
         }];

    // Location updates signal does not include any error events. So,
    // we merge it with the error signal to get the error events.
    //
    // We also need to replay the most recent location value to later
    // subscribers, so that they will get the location updates too.
    // Otherwise, they may subscribe after the location update event
    // and get nothing.
    return [[[RACSignal merge:@[locationUpdates, self.errorSignal]]
             replayLastLazily]
             setNameWithFormat:@"%@ -locationUpdatesSignal", self];
}

/**
 * Signal that sends an error event when location services failed to
 * retrieve a location value.
 */
- (RACSignal *)errorSignal
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
            setNameWithFormat:@"%@ -errorSignal", self];
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

@end

