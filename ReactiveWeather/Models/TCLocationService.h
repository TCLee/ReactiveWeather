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
 * @param locationManager The @c CLLocationManager instance that will be used 
 *                        to find the user's current location. The location 
 *                        service object will be set as the delegate of the
 *                        @c CLLocationManager instance to receive location 
 *                        updates. Must not be @c nil.
 * @param maxLocationAge  Location data that is older than this limit will 
 *                        be discarded. The age is measured in seconds.
 *
 * @return A location service object initialized with the given 
 *         @c CLLocationManager instance.
 */
- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager
                         maxLocationAge:(NSTimeInterval)maxLocationAge;

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
