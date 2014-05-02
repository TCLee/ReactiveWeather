//
//  TCHourlyForecastViewModel.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "RVMViewModel.h"

@class TCWeather;

@interface TCHourlyForecastViewModel : RVMViewModel

@property (nonatomic, copy, readonly) NSDate *dateAndTime;
@property (nonatomic, copy, readonly) NSNumber *temperature;
@property (nonatomic, copy, readonly) NSString *iconName;

- (instancetype)initWithWeather:(TCWeather *)weather;

@end
