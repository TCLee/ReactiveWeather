//
//  TCCurrentConditionViewModel.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/29/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCCurrentConditionViewModel.h"
#import "TCWeather.h"

@implementation TCCurrentConditionViewModel

- (instancetype)initWithWeather:(TCWeather *)weather
{
    self = [super init];
    if (nil == self) { return nil; }

    _cityName = [weather.locationName copy];
    _condition = [weather.condition copy];
    _iconName = [weather.imageName copy];
    _currentTemperature = [weather.temperature copy];
    _minTemperature = [weather.tempLow copy];
    _maxTemperature = [weather.tempHigh copy];

    return self;
}

@end
