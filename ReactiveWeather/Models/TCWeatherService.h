//
//  TCWeatherService.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/11/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

/**
 * The service class that sends requests to the @b OpenWeatherMap API.
 */
@interface TCWeatherService : NSObject

/**
 * Fetches the current weather condition for the given coordinates.
 *
 * @param coordinate The coordinate of a location.
 *
 * @return A signal that will send a @c TCWeather instance
 *         then complete.
 */
- (RACSignal *)currentConditionForLocation:(CLLocationCoordinate2D)coordinate;

/**
 * Fetches the hourly forecasts for the given coordinates.
 *
 * @param coordinate The coordinate of a location.
 * @param limitTo    Limit the number of forecasts to @c `count`.
 *
 * @return A signal that will send an array of @c TCWeather
 *         objects then complete.
 */
- (RACSignal *)hourlyForecastsForLocation:(CLLocationCoordinate2D)coordinate
                                  limitTo:(NSUInteger)count;

/**
 * Fetches the daily forecasts for the given coordinates.
 *
 * @param coordinate The coordinate of a location.
 * @param limitTo    Limit the number of forecasts to @c `count`.
 *
 * @return A signal that will send an array of @c TCWeather
 *         objects then complete.
 */
- (RACSignal *)dailyForecastsForLocation:(CLLocationCoordinate2D)coordinate
                                 limitTo:(NSUInteger)count;

@end
