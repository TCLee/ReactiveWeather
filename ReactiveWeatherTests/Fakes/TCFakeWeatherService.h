//
//  TCFakeWeatherService.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/13/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherService.h"

@class TCWeather;

@interface TCFakeWeatherService : TCWeatherService

/**
 * The fake weather object that is returned from @c 
 * currentConditionForLocation: signal.
 */
@property (nonatomic, strong, readonly) TCWeather *fakeCurrentCondition;

/**
 * The array of fake weather objects that is returned from @c
 * hourlyForecastsForLocation:limitTo: signal.
 */
@property (nonatomic, copy, readonly) NSArray *fakeHourlyForecasts;

/**
 * The array of fake weather objects that is returned from @c
 * dailyForecastsForLocation:limitTo: signal.
 */
@property (nonatomic, copy, readonly) NSArray *fakeDailyForecasts;

/**
 * Returns a new initialized fake weather service object for use in 
 * unit tests.
 */
- (instancetype)init;

@end
