//
//  TCHourlyForecastViewModel.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCHourlyForecastViewModel.h"
#import "TCWeather.h"

@implementation TCHourlyForecastViewModel

- (instancetype)initWithWeather:(TCWeather *)weather
{
    NSParameterAssert(nil != weather);

    self = [super init];
    if (nil == self) { return nil; }

    _dateAndTime = weather.date;
    _temperature = weather.temperature;

    return self;
}

@end
