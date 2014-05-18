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
 * The number of location updates that are currently running.
 *
 * Each time @c startUpdatingLocation is called this value is incremented.
 * Each time @c stopUpdatingLocation is called this value is decremented.
 */
@property (nonatomic, assign, readonly) NSInteger numberOfLocationUpdatesInProgress;

@end
