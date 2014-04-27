//
//  TCDailyForecastViewModel.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>

@class TCWeather;

@interface TCDailyForecastViewModel : RVMViewModel

@property (nonatomic, copy, readonly) NSDate *date;
@property (nonatomic, copy, readonly) NSNumber *maxTemperature;
@property (nonatomic, copy, readonly) NSNumber *minTemperature;

- (instancetype)initWithWeather:(TCWeather *)weather;

@end
