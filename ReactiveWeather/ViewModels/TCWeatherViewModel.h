//
//  TCWeatherViewModel.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

@class TCWeatherService;
@class TCLocationService;
@class TCWeather;

#import <ReactiveViewModel/ReactiveViewModel.h>

@interface TCWeatherViewModel : RVMViewModel

/**
 * The current weather data or @c nil if weather data has 
 * not been loaded yet.
 */
@property (nonatomic, strong, readonly) TCWeather *currentWeather;

/**
 * The hourly forecast weather data or @c nil if weather data 
 * has not been loaded yet.
 */
@property (nonatomic, copy, readonly) NSArray *hourlyForecasts;

/**
 * The daily forecast weather data or @c nil if weather data has 
 * not been loaded yet.
 */
@property (nonatomic, copy, readonly) NSArray *dailyForecasts;

/**
 * Finds the user's current location and fetches the weather data
 * for the given location.
 *
 * This will be automatically executed when the view model becomes active or
 * when user requests the weather data to be refreshed manually.
 */
@property (nonatomic, strong, readonly) RACCommand *fetchWeatherCommand;

/**
 * Initializes the view model with the given service classes for accessing 
 * location and weather data.
 *
 * @param locationService The location service used to find
 *                        the user's current location.
 * @param weatherService  The weather service used to fetch the weather data.
 *
 * @return The initialized view model.
 */
- (instancetype)initWithLocationService:(TCLocationService *)locationService
                         weatherService:(TCWeatherService *)weatherService;

@end
