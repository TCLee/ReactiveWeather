//
//  TCFakeLocationService.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/13/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCLocationService.h"

@interface TCFakeLocationService : TCLocationService

/**
 * The fake location that is returned from @c currentLocation signal.
 */
@property (nonatomic, strong, readonly) CLLocation *fakeLocation;

/**
 * Returns a new initialized fake location service object for use in
 * unit tests.
 */
- (instancetype)init;

@end
