//
//  TCFakeLocationManager.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/8/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

@interface TCFakeLocationManager : CLLocationManager

/**
 * Returns @b YES after @c startUpdatingLocation is called.
 * Returns @b NO after @c stopUpdatingLocation is called.
 */
@property (nonatomic, getter = isUpdatingLocation, readonly) BOOL updatingLocation;

@end
