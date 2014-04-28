//
//  TCWeatherViewModel.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherViewModel.h"
#import "TCHourlyForecastViewModel.h"
#import "TCDailyForecastViewModel.h"
#import "TCWeather.h"
#import "TCWeatherService.h"
#import "TCLocationService.h"
#import "RACSignal+TCOperatorAdditions.h"

@interface TCWeatherViewModel ()

/**
 * The service class used to access the weather web service.
 */
@property (nonatomic, strong) TCWeatherService *weatherService;

/**
 * The service class used to provide access to the Core Location
 * services framework.
 */
@property (nonatomic, strong) TCLocationService *locationService;

@property (nonatomic, strong) TCWeather *currentWeather;
@property (nonatomic, copy) NSArray *hourlyForecasts;
@property (nonatomic, copy) NSArray *dailyForecasts;

@end

@implementation TCWeatherViewModel

- (instancetype)initWithLocationService:(TCLocationService *)locationService weatherService:(TCWeatherService *)weatherService
{
    self = [super init];
    if (!self) { return nil; }

    _locationService = locationService;
    _weatherService  = weatherService;

    _fetchWeatherCommand =
        [[RACCommand alloc] initWithSignalBlock:^(id _) {
            return [self fetchWeather];
        }];

    // When this view model has become active, we want to
    // automatically fetch the weather data by executing the command.
    [self.didBecomeActiveSignal
     subscribeNext:^(TCWeatherViewModel *viewModel) {
         [viewModel.fetchWeatherCommand execute:nil];
     }];

    return self;
}

/**
 * Fetches the latest weather data for the user's current location.
 *
 * @return A signal that will send @c complete when the latest weather
 *         data has been fetched or @c error if the operation failed.
 */
- (RACSignal *)fetchWeather
{
    return [[[[[[self.locationService currentLocation]
        // Take only 1 location value, since we don't need to track the user.
        take:1]
        // With the current location, we can fetch the latest weather data and
        // update the view model's properties.
        map:^(CLLocation *location) {
            return [[RACSignal merge:@[
                [self updateCurrentWeatherConditionForLocation:location],
                [self updateHourlyForecastForLocation:location],
                [self updateDailyForecastForLocation:location]
            ]]
            // Not interested in any values from the signal, since
            // we're updating the view model's properties only.
            ignoreValues];
        }]
        // If current location changes, we want to cancel any in-flight
        // weather data requests.
        switchToLatest]
        logError]
        setNameWithFormat:@"%@ -fetchWeather", self];
}

/**
 * Fetches the latest current weather data and updates the view
 * model's property.
 */
- (RACSignal *)updateCurrentWeatherConditionForLocation:(CLLocation *)location
{
    return [[[self.weatherService
            currentConditionForLocation:location.coordinate]
            deliverOn:RACScheduler.mainThreadScheduler]
            doNext:^(TCWeather *currentCondition) {
                self.currentWeather = currentCondition;
            }];
}

/**
 * Fetches the latest hourly forecast data and updates the view
 * model's property.
 */
- (RACSignal *)updateHourlyForecastForLocation:(CLLocation *)location
{
    // Map each `TCHourlyForecast` element in the array into an
    // `TCHourlyForecastViewModel`.
    return [[[[self.weatherService hourlyForecastsForLocation:location.coordinate]
        tc_mapArray:^(TCWeather *weather) {
            return [[TCHourlyForecastViewModel alloc] initWithWeather:weather];
        }]
        deliverOn:RACScheduler.mainThreadScheduler]
        doNext:^(NSArray *forecastViewModels) {
            self.hourlyForecasts = forecastViewModels;
        }];;
}

/**
 * Fetches the latest daily forecast data and updates the view
 * model's property.
 */
- (RACSignal *)updateDailyForecastForLocation:(CLLocation *)location
{
    // Map each `TCDailyForecast` element in the array into an
    // `TCDailyForecastViewModel`.
    return [[[[self.weatherService dailyForecastsForLocation:location.coordinate]
        tc_mapArray:^(TCWeather *weather) {
            return [[TCDailyForecastViewModel alloc] initWithWeather:weather];
        }]
        deliverOn:RACScheduler.mainThreadScheduler]
        doNext:^(NSArray *forecastViewModels) {
            self.dailyForecasts = forecastViewModels;
        }];
}

@end
