//
//  NSDateFormatter+TCForecastFormattingAdditions.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "NSDateFormatter+TCForecastFormattingAdditions.h"

@implementation NSDateFormatter (TCForecastFormattingAdditions)

+ (NSDateFormatter *)sharedDateFormatter
{
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
    });

    return _dateFormatter;
}

- (NSString *)forecastHourStringFromDate:(NSDate *)date
{
    self.class.sharedDateFormatter.dateFormat = @"h a";
    return [self stringFromDate:date];
}

- (NSString *)forecastDayStringFromDate:(NSDate *)date
{
    self.class.sharedDateFormatter.dateFormat = @"EEEE";
    return [self stringFromDate:date];
}

@end
