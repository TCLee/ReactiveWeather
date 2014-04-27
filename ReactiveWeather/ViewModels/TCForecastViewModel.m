//
//  TCForecastViewModel.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCForecastViewModel.h"

@implementation TCForecastViewModel

- (instancetype)initWithForecast:(TCWeather *)weather
{
    NSParameterAssert(nil != weather);

    self = [super init];
    if (nil == self) { return nil; }

    _weather = weather;

    return self;
}

@end
