//
//  TCUserLocation.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

typedef void(^TCUserLocationSuccessBlock)(CLLocation *location);
typedef void(^TCUserLocationFailureBlock)(NSError *error);

/**
 * This class encapsulates the Core Location code to find the 
 * user's current location.
 */
@interface TCUserLocation : NSObject <CLLocationManagerDelegate>

- (void)findCurrentLocationWithSuccess:(TCUserLocationSuccessBlock)success
                               failure:(TCUserLocationFailureBlock)failure;

@end
