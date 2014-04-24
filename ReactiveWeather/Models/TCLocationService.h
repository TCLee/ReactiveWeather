//
//  TCLocationService.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

/**
 * The location service class provides a reactive API on top
 * of the Core Location services framework.
 */
@interface TCLocationService : NSObject 

/**
 * A signal of location updates.
 *
 * This signal sends location updates as soon as it has at least
 * one subscriber and stops when there are no more subscribers.
 * It will automatically restart the location updates again when there is
 * at least one subscriber.
 *
 * @return A signal which will send location updates or an error event. 
 *         This is an infinite signal, so use the @c take: operators to
 *         terminate this signal.
 */
- (RACSignal *)currentLocationSignal;

/**
 * Signal of @c NSNumber @c (BOOL) values to determine if this app is
 * authorized to use location services.
 */
- (RACSignal *)authorizedSignal;

@end
