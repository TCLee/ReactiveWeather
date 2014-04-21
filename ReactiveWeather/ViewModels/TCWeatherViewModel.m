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

//@property (nonatomic, strong) TCWeather *currentWeather;
//@property (nonatomic, copy) NSArray *hourlyForecasts;
//@property (nonatomic, copy) NSArray *dailyForecasts;

@end

@implementation TCWeatherViewModel

- (instancetype)initWithLocationService:(TCLocationService *)locationService weatherService:(TCWeatherService *)weatherService
{
    self = [super init];
    if (!self) { return nil; }

    _locationService = locationService;
    _weatherService  = weatherService;

    // Signal of user's current location.
    RACSignal *currentLocationSignal = [self.locationService locationSignal];

    // Weather service will use the location data from the current
    // location signal to create 3 individual weather data signals.
    // (i.e. splitting the current location signal)
    RACSignal *currentWeatherSignal  =
        [currentLocationSignal flattenMap:^(CLLocation *location) {
            return [self.weatherService
                    currentConditionForLocation:location.coordinate];
        }];
    RACSignal *hourlyForecastsSignal =
        [currentLocationSignal flattenMap:^(CLLocation *location) {
            return [self.weatherService
                    hourlyForecastsForLocation:location.coordinate];
        }];
    RACSignal *dailyForecastsSignal  =
        [currentLocationSignal flattenMap:^(CLLocation *location) {
            return [self.weatherService
                    dailyForecastsForLocation:location.coordinate];
        }];

    // Bind the weather data properties to their signals.
    // Before binding we have to make sure the signal is "safe" for binding.
    RAC(self, currentWeather)  = [self safeSignalForBinding:currentWeatherSignal];
    RAC(self, hourlyForecasts) = [self safeSignalForBinding:hourlyForecastsSignal];
    RAC(self, dailyForecasts)  = [self safeSignalForBinding:dailyForecastsSignal];

    // When the command is executed, it will find the user's current location
    // and then fetch all the weather data. We merge the various signals
    // together to perform the operations as a single group.
    _fetchWeatherCommand =
        [[RACCommand alloc] initWithSignalBlock:^(id input) {
            return [RACSignal merge:@[currentLocationSignal,
                                      currentWeatherSignal,
                                      hourlyForecastsSignal,
                                      dailyForecastsSignal]];
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
 * Returns a signal that is safe for binding to properties.
 *
 * @param unsafeSignal An unsafe signal in this case means a signal that 
 *                     sends its values on another thread that is not the main 
 *                     thread and could possibly send an error event.
 *
 * @return A signal that is guaranteed to be safe for binding to properties using the @c RAC() macro.
 */
- (RACSignal *)safeSignalForBinding:(RACSignal *)unsafeSignal
{
    return [[[unsafeSignal
              logError]
              catchTo:RACSignal.empty]
              deliverOn:RACScheduler.mainThreadScheduler];
}

@end
