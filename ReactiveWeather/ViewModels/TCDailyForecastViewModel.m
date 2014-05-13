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
    _iconName = [weather.imageName copy];

    return self;
}

- (BOOL)isEqualToDailyForecastViewModel:(TCDailyForecastViewModel *)other
{
    return (
        (self.date == other.date || [self.date isEqualToDate:other.date]) &&
        (self.maxTemperature == other.maxTemperature || [self.maxTemperature isEqualToNumber:other.maxTemperature]) &&
        (self.minTemperature == other.minTemperature || [self.minTemperature isEqualToNumber:other.minTemperature]) &&
        (self.iconName == other.iconName || [self.iconName isEqualToString:other.iconName])
    );
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (object == self) { return YES; }
    if (![object isKindOfClass:self.class]) { return NO; }

    return [self isEqualToDailyForecastViewModel:object];
}

- (NSUInteger)hash
{
    return (
        self.date.hash ^
        self.maxTemperature.hash ^
        self.minTemperature.hash ^
        self.iconName.hash
    );
}

@end
