//
//  TCLocationService.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

#import "TCLocationService.h"

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

- (RACSignal *)currentLocationSignal
{
    __block NSUInteger subscriberCount = 0;
    __block RACDisposable *subjectDisposable = nil;
    __block RACSubject *locationSubject = nil;

    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @synchronized(self) {
            // If this is the first subscriber to this signal, start the
            // location updates.
            if (++subscriberCount == 1) {
                [self.locationManager startUpdatingLocation];

                // Location updates signal and error signal will only have the
                // subject as the subscriber.

                locationSubject = [RACReplaySubject
                                   replaySubjectWithCapacity:1];
                subjectDisposable = [[self locationUpdatesSignal]
                                     subscribe:locationSubject];

                [[self locationUpdatesSignal] subscribe:locationSubject];

                [[self errorSignal] subscribeNext:^(NSError *error) {
                    [locationSubject sendError:error];
                }];
            }
        }

        // Subscribers will be connected to the subject, so that they can
        // share the same location data.
        [locationSubject subscribe:subscriber];

        return [RACDisposable disposableWithBlock:^{
            @synchronized(self) {
                // If we have no more subscribers, we will stop the
                // location updates. It will be restarted again, when
                // this signal has new subscribers.
                if (--subscriberCount == 0) {
                    [self.locationManager stopUpdatingLocation];
                }
            }
        }];
    }] setNameWithFormat:@"%@ -currentLocationSignal", self];
}

- (RACSignal *)authorizedSignal
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
             setNameWithFormat:@"%@ -authorizedSignal", self];
}

#pragma mark Private Methods

/**
 * Signal of location updates sent by location services when it has started.
 */
- (RACSignal *)locationUpdatesSignal
{
    return [[[[self valueForCLLocationManagerDelegateSelector:
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
}

/**
 * Signal of @c NSError objects sent by location services on failure
 * to retrieve location.
 */
- (RACSignal *)errorSignal
{
    return [[self valueForCLLocationManagerDelegateSelector:
             @selector(locationManager:didFailWithError:)]
             filter:^BOOL(NSError *error) {
                 // If the location service is unable to retrieve a location
                 // right away, it reports a kCLErrorLocationUnknown error and
                 // keeps trying. In such a situation, you can simply ignore the
                 // error and wait for a new event.
                 return !(error.domain == kCLErrorDomain &&
                          error.code == kCLErrorLocationUnknown);
             }];
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

