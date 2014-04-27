//
//  TCDailyForecastViewModel.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCDailyForecastViewModel.h"
#import "TCWeather.h"

@implementation TCDailyForecastViewModel

- (instancetype)initWithWeather:(TCWeather *)weather
{
    NSParameterAssert(nil != weather);

    self = [super init];
    if (nil == self) { return nil; }

    _date = [weather.date copy];
    _maxTemperature = [weather.tempHigh copy];
    _minTemperature = [weather.tempLow copy];

    return self;
}

@end
