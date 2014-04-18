//
//  TCUserLocation.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

/**
 * This class encapsulates the Core Location code to find the 
 * user's current location.
 */
@interface TCUserLocation : NSObject <CLLocationManagerDelegate>

/**
 * Starts the location service to find the user's current location.
 *
 * @return A signal that will send the user's current location 
 *         then complete.
 */
- (RACSignal *)currentLocation;

@end
