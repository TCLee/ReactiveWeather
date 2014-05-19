//
//  TCWeatherViewModel.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherViewModel.h"
#import "TCCurrentConditionViewModel.h"
#import "TCHourlyForecastViewModel.h"
#import "TCDailyForecastViewModel.h"
#import "TCWeatherService.h"
#import "TCLocationService.h"
#import "NSArray+TCSignalSupport.h"

@interface TCWeatherViewModel ()

/**
 * The service class used to access the weather web service.
 */
@property (nonatomic, strong, readonly) TCWeatherService *weatherService;

/**
 * The service class used to provide access to the Core Location
 * services framework.
 */
@property (nonatomic, strong, readonly) TCLocationService *locationService;

@property (nonatomic, strong) TCCurrentConditionViewModel *currentCondition;
@property (nonatomic, copy) NSArray *hourlyForecasts;
@property (nonatomic, copy) NSArray *dailyForecasts;

@end

@implementation TCWeatherViewModel

- (instancetype)initWithLocationService:(TCLocationService *)locationService
                         weatherService:(TCWeatherService *)weatherService
                    hourlyForecastLimit:(NSUInteger)hourlyForecastCount
                     dailyForecastLimit:(NSUInteger)dailyForecastCount
{
    NSParameterAssert(nil != locationService);
    NSParameterAssert(nil != weatherService);

    self = [super init];
    if (nil == self) { return nil; }

    _locationService = locationService;
    _weatherService  = weatherService;

    @weakify(self);
    _fetchWeatherCommand = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        @strongify(self);
        return [self fetchWeatherWithHourlyForecastLimit:hourlyForecastCount
                                      dailyForecastLimit:dailyForecastCount];
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
 * Fetches the latest weather data at the user's current location and 
 * updates the view model's properties.
 *
 * @return A signal that will send @c `complete` when the latest weather
 *         data has been fetched or @c `error` if the operation failed.
 */
- (RACSignal *)fetchWeatherWithHourlyForecastLimit:(NSUInteger)hourlyForecastCount
                                dailyForecastLimit:(NSUInteger)dailyForecastCount
{
    return [[[[self.locationService currentLocation]
        // Take only 1 location value, since we don't need to track the user.
        take:1]
        flattenMap:^(CLLocation *location) {
            // The merged signal will only contain one complete or error event,
            // since all the update signals will `ignoreValues`.
            return [RACSignal merge:@[
                [self updateCurrentConditionForLocation:location],
                [self updateHourlyForecastForLocation:location withLimit:hourlyForecastCount],
                [self updateDailyForecastForLocation:location withLimit:dailyForecastCount]
            ]];
        }]
        setNameWithFormat:@"%@ -fetchWeatherWithHourlyForecastLimit: %lu dailyForecastLimit: %lu", self, (unsigned long)hourlyForecastCount, (unsigned long)dailyForecastCount];
}

/**
 * Fetches the latest current weather data and updates the view
 * model's property.
 */
- (RACSignal *)updateCurrentConditionForLocation:(CLLocation *)location
{
    return [[[[[[self.weatherService currentConditionForLocation:location.coordinate]
        map:^(TCWeather *weather) {
            return [[TCCurrentConditionViewModel alloc] initWithWeather:weather];
        }]
        deliverOn:RACScheduler.mainThreadScheduler]
        doNext:^(TCCurrentConditionViewModel *currentCondition) {
            self.currentCondition = currentCondition;
        }]
        // Not interested in any values from the signal, since
        // we're updating the view model's properties only.
        ignoreValues]
        setNameWithFormat:@"%@ -updateCurrentConditionForLocation: %@", self, location];
}

/**
 * Fetches the latest hourly forecast data and updates the view
 * model's property.
 */
- (RACSignal *)updateHourlyForecastForLocation:(CLLocation *)location
                                     withLimit:(NSUInteger)count
{
    return [[self updateForecastsWithSignal:[self.weatherService hourlyForecastsForLocation:location.coordinate limitTo:count]
        mapEach:^(TCWeather *weather) {
            return [[TCHourlyForecastViewModel alloc] initWithWeather:weather];
        }
        doUpdate:^(NSArray *viewModels) {
            self.hourlyForecasts = viewModels;
        }]
        setNameWithFormat:@"%@ -updateHourlyForecastForLocation: %@ withLimit: %lu", self, location, (unsigned long)count];
}

/**
 * Fetches the latest daily forecast data and updates the view
 * model's property.
 */
- (RACSignal *)updateDailyForecastForLocation:(CLLocation *)location
                                    withLimit:(NSUInteger)count
{
    return [[self updateForecastsWithSignal:[self.weatherService dailyForecastsForLocation:location.coordinate limitTo:count]
        mapEach:^(TCWeather *weather) {
            return [[TCDailyForecastViewModel alloc] initWithWeather:weather];
        }
        doUpdate:^(NSArray *viewModels) {
            self.dailyForecasts = viewModels;
        }]
        setNameWithFormat:@"%@ -updateDailyForecastForLocation: %@ withLimit: %lu", self, location, (unsigned long)count];
}

- (RACSignal *)updateForecastsWithSignal:(RACSignal *)signal
                                 mapEach:(id (^)(id value))mapBlock
                                doUpdate:(void (^)(id value))doUpdateBlock
{
    return [[[[signal
        flattenMap:^(NSArray *forecasts) {
            // Map each model element in the array into a
            // corresponding view model.
            return [[forecasts.rac_signal map:mapBlock] collect];
        }]
        deliverOn:RACScheduler.mainThreadScheduler]
        doNext:doUpdateBlock]
        // Not interested in any values from the signal, since
        // we're updating the view model's properties only.
        ignoreValues];
}

@end
