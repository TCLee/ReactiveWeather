//
//  TCLocationService.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

/**
 * The location service class encapsulates the code to find the user's
 * current location.
 */
@interface TCLocationService : NSObject 

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
