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

- (BOOL)isEqualToHourlyForecastViewModel:(TCHourlyForecastViewModel *)other
{
    return (
        (self.dateAndTime == other.dateAndTime || [self.dateAndTime isEqualToDate:other.dateAndTime]) &&
        (self.temperature == other.temperature || [self.temperature isEqualToNumber:other.temperature]) &&
        (self.iconName == other.iconName || [self.iconName isEqualToString:other.iconName])
    );
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (object == self) { return YES; }
    if (![object isKindOfClass:self.class]) { return NO; }

    return [self isEqualToHourlyForecastViewModel:object];
}

- (NSUInteger)hash
{
    return (
        self.dateAndTime.hash ^
        self.temperature.hash ^
        self.iconName.hash
    );
}

@end
