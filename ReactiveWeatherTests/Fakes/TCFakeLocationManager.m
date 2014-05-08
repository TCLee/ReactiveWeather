//
//  TCFakeLocationManager.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/8/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCFakeLocationManager.h"

@implementation TCFakeLocationManager

- (void)startUpdatingLocation
{
    _updatingLocation = YES;
}

- (void)stopUpdatingLocation
{
    _updatingLocation = NO;
}

@end
