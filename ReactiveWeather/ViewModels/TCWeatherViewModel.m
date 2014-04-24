//
//  TCWeatherViewModel.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherViewModel.h"
#import "TCWeather.h"
#import "TCWeatherService.h"
#import "TCLocationService.h"

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

@property (nonatomic, strong) CLLocation *currentLocation;
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
        [[RACCommand alloc] initWithSignalBlock:^(__unused id input) {
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
    // Take only 1 location value, since we don't need to track the user.
    RAC(self, currentLocation) =
        [[self.locationService currentLocation] take:1];

    // Skip 1 to skip the initial value and ignore nil values, since
    // we can't do anything with a `nil` location.
    RACSignal *currentLocationSignal = [[RACObserve(self, currentLocation)
                                         skip:1]
                                         ignore:nil];

    return [[RACSignal
            merge:@[[self updateCurrentWeatherConditionWithLocation:currentLocationSignal],
                    [self updateHourlyForecastWithLocation:currentLocationSignal],
                    [self updateDailyForecastWithLocation:currentLocationSignal]]]
            ignoreValues];
}

/** 
 * Fetches the latest current weather data and updates the view 
 * model's property.
 */
- (RACSignal *)updateCurrentWeatherConditionWithLocation:(RACSignal *)locationSignal
{
    return [[locationSignal
            flattenMap:^(CLLocation *location) {
                return [self.weatherService
                        currentConditionForLocation:location.coordinate];
            }]
            doNext:^(TCWeather *currentWeatherCondition) {
                self.currentWeather = currentWeatherCondition;
            }];
}

/**
 * Fetches the latest hourly forecast data and updates the view
 * model's property.
 */
- (RACSignal *)updateHourlyForecastWithLocation:(RACSignal *)locationSignal
{
    return [[locationSignal
            flattenMap:^(CLLocation *location) {
                return [self.weatherService
                        hourlyForecastsForLocation:location.coordinate];
            }]
            doNext:^(NSArray *hourlyForecasts) {
                self.hourlyForecasts = hourlyForecasts;
            }];
}

/**
 * Fetches the latest daily forecast data and updates the view
 * model's property.
 */
- (RACSignal *)updateDailyForecastWithLocation:(RACSignal *)locationSignal
{
    return [[locationSignal
            flattenMap:^(CLLocation *location) {
                return [self.weatherService
                        dailyForecastsForLocation:location.coordinate];
            }]
            doNext:^(NSArray *dailyForecasts) {
                self.dailyForecasts = dailyForecasts;
            }];
}

@end
