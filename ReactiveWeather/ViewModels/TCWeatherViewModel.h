//
//  TCWeatherViewModel.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@class TCWeatherService;
@class TCLocationService;
@class TCCurrentConditionViewModel;

#import <ReactiveViewModel/ReactiveViewModel.h>

@interface TCWeatherViewModel : RVMViewModel

/**
 * The current weather data or @c nil if weather data has 
 * not been loaded yet.
 */
@property (nonatomic, strong, readonly) TCCurrentConditionViewModel *currentCondition;

/**
 * The list of @c TCHourlyForecastViewModel objects, in the order they should
 * be presented to the user.
 */
@property (nonatomic, copy, readonly) NSArray *hourlyForecasts;

/**
 * The list of @c TCDailyForecastViewModel objects, in the order they should
 * be presented to the user.
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
 * @param locationService     The location service used to find
 *                            the user's current location.
 * @param weatherService      The weather service used to fetch the weather 
 *                            data.
 * @param hourlyForecastCount Limits the number of hourly forecasts
 *                            fetched to @c `hourlyForecastCount`.
 * @param dailyForecastCount  Limits the number of daily forecasts
 *                            fetched to @c `dailyForecastCount`.
 *
 * @return The initialized view model.
 */
- (instancetype)initWithLocationService:(TCLocationService *)locationService
                         weatherService:(TCWeatherService *)weatherService
                    hourlyForecastLimit:(NSUInteger)hourlyForecastCount
                     dailyForecastLimit:(NSUInteger)dailyForecastCount;

@end
