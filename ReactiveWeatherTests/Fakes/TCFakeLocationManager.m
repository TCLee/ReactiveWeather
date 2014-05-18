//
//  TCFakeLocationManager.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/8/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCFakeLocationManager.h"

@implementation TCFakeLocationManager

- (instancetype)init
{
    self = [super init];
    if (nil == self) { return nil; }

    _numberOfLocationUpdatesInProgress = 0;

    return self;
}

- (void)startUpdatingLocation
{
    _numberOfLocationUpdatesInProgress++;
}

- (void)stopUpdatingLocation
{
    _numberOfLocationUpdatesInProgress--;
}

@end
