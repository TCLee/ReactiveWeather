//
//  CLLocation+TCDebugAdditions.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/29/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

/**
 * Returns the coordinate as a string.
 *
 * @param coordinate The @c CLLocationCoordinate2D value.
 *
 * @return A string representing the @c `coordinate` latitude and longitude.
 */
NSString *tc_NSStringFromCoordinate(CLLocationCoordinate2D coordinate);

@interface CLLocation (TCDebugAdditions)

@end
