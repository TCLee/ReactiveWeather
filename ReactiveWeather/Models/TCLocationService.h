//
//  TCLocationService.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

/**
 * The location service class encapsulates the code to find the user's
 * current location.
 */
@interface TCLocationService : NSObject <CLLocationManagerDelegate>

/**
 * Initializes and returns a location service object.
 *
 * @param accuracy       The accuracy of the location data.
 * @param distanceFilter The minimum distance (measured in meters) a device must move 
 *                       horizontally before a location update event is generated.
 * @param maxCacheAge    Cached location data that is older than this 
 *                       maximum limit will be discarded. The age is 
 *                       calculated in seconds.
 *
 * @return A location service object initialized with the given values.
 */
- (instancetype)initWithAccuracy:(CLLocationAccuracy)accuracy
                  distanceFilter:(CLLocationDistance)distanceFilter
                     maxCacheAge:(NSTimeInterval)maxCacheAge;

/**
 * A signal of location updates.
 *
 * This signal automatically starts the location service as soon as it 
 * has the first subscriber and stops the location service when there are 
 * no more subscribers.
 *
 * @return A signal which will send location updates or an error event. 
 *         This is an infinite signal, so use the @c take: operators to
 *         terminate this signal earlier.
 */
- (RACSignal *)currentLocation;

/**
 * Signal of @c NSNumber @c (BOOL) values to determine if this app is
 * authorized to use location services.
 */
- (RACSignal *)isAuthorized;

@end
