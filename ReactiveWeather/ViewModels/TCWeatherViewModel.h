//
//  TCWeatherViewModel.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>

@class TCWeather;

@interface TCWeatherViewModel : RVMViewModel

@property (nonatomic, strong, readonly) TCWeather *currentWeather;

@property (nonatomic, strong, readonly) NSArray *hourlyForecasts;

@property (nonatomic, strong, readonly) NSArray *dailyForecasts;

/**
 * Finds the user's current location and fetches the weather data for that
 * location.
 *
 * This will be automatically executed when this view model becomes active.
 */
@property (nonatomic, strong, readonly) RACCommand *fetchWeatherCommand;

@end
