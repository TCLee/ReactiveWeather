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

- (BOOL)isEqualToCurrentConditionViewModel:(TCCurrentConditionViewModel *)other
{
    return (
        (self.cityName == other.cityName || [self.cityName isEqualToString:other.cityName]) &&
        (self.condition == other.condition || [self.condition isEqualToString:other.condition]) &&
        (self.iconName == other.iconName || [self.iconName isEqualToString:other.iconName]) &&
        (self.currentTemperature == other.currentTemperature || [self.currentTemperature isEqualToNumber:other.currentTemperature]) &&
        (self.minTemperature == other.minTemperature || [self.minTemperature isEqualToNumber:other.minTemperature]) &&
        (self.maxTemperature == other.maxTemperature || [self.maxTemperature isEqualToNumber:other.maxTemperature])
    );
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object
{
    if (object == self) { return YES; }
    if (![object isKindOfClass:self.class]) { return NO; }

    return [self isEqualToCurrentConditionViewModel:object];
}

- (NSUInteger)hash
{
    return (
        self.cityName.hash ^
        self.condition.hash ^
        self.iconName.hash ^
        self.currentTemperature.hash ^
        self.maxTemperature.hash ^
        self.minTemperature.hash
    );
}

@end
