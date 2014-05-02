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

    _dateAndTime = [weather.date copy];
    _temperature = [weather.temperature copy];
    _iconName = [weather.imageName copy];

    return self;
}

@end
