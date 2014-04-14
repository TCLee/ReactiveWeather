//
//  TCUserLocation.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCUserLocation.h"

/**
 * Cached location data that is older than this maximum limit will be
 * discarded.
 */
static const NSTimeInterval TCMaxAcceptableLocationAge = 60.0f;

@interface TCUserLocation ()

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) TCUserLocationSuccessBlock successBlock;
@property (nonatomic, copy) TCUserLocationFailureBlock failureBlock;

@end

@implementation TCUserLocation

- (instancetype)init
{
    self = [super init];

    if (self) {
        _locationManager = [[CLLocationManager alloc] init];

        // Since we're getting the weather forecast for a city, we do not
        // need very accurate location data.
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        _locationManager.distanceFilter = 1000;
    }

    return self;
}

- (void)findCurrentLocationWithSuccess:(TCUserLocationSuccessBlock)success
                               failure:(TCUserLocationFailureBlock)failure
{
    NSParameterAssert(success);
    NSParameterAssert(failure);

    self.successBlock = success;
    self.failureBlock = failure;

    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // Get the most recent location data, which is at the end of the array.
    CLLocation *latestLocation = [locations lastObject];

    // Make sure the location data is not too old. Otherwise, we will be
    // using stale location data.
    NSTimeInterval locationAge = [latestLocation.timestamp timeIntervalSinceNow];
    if (abs(locationAge <= TCMaxAcceptableLocationAge)) {
        // Callback with location data and stop location services to
        // save battery power.
        [manager stopUpdatingLocation];
        self.successBlock(latestLocation);
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    // If the location service is unable to retrieve a location
    // right away, it reports a kCLErrorLocationUnknown error and
    // keeps trying. In such a situation, you can simply ignore the
    // error and wait for a new event.
    if (error.domain == kCLErrorDomain &&
        error.code == kCLErrorLocationUnknown) {
        return;
    }

    // If the user denies your application’s use of the location service,
    // it reports a kCLErrorDenied error. Upon receiving such an error, you
    // should stop the location service. When user re-enables permission
    // for your app, you can restart the location service.
    if (error.domain == kCLErrorDomain &&
        error.code == kCLErrorDenied) {
        [manager stopUpdatingLocation];
        return;
    }

    // For any other errors, we stop the location service and
    // callback with error.
    [manager stopUpdatingLocation];
    self.failureBlock(error);
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        // User has authorized us to use location services, so
        // we can start locating the user.
        case kCLAuthorizationStatusAuthorized:
            [manager startUpdatingLocation];
            break;

        // Our app has been denied access to location service, so
        // stop asking for location updates.
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            [manager stopUpdatingLocation];
            break;

        default:
            break;
    }
}

@end
