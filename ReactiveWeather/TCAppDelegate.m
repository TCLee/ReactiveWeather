//
//  TCAppDelegate.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/10/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

#import "TCAppDelegate.h"

#import "TCWeatherViewController.h"
#import "TCWeatherViewModel.h"
#import "TCLocationService.h"
#import "TCWeatherService.h"

@implementation TCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // We do not need very high accuracy for the location services, since
    // we're only using the location to fetch weather data for a city.
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 1000;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;

    TCLocationService *locationService =
        [[TCLocationService alloc] initWithLocationManager:locationManager
                                            maxLocationAge:15];

    // Create the NSURLSession for the weather service to fetch the weather data.
    NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfiguration];
    TCWeatherService *weatherService = [[TCWeatherService alloc] initWithSession:session];

    // Create the view model with the given service classes.
    // FIXME: Forecast limits should be configured from user settings.
    TCWeatherViewModel *viewModel =
        [[TCWeatherViewModel alloc] initWithLocationService:locationService
                                             weatherService:weatherService
                                        hourlyForecastLimit:6
                                         dailyForecastLimit:6];

    // Pass the view model to the view layer (view controller + view).
    TCWeatherViewController *viewController =
        (TCWeatherViewController *) self.window.rootViewController;
    viewController.viewModel = viewModel;

    return YES;
}

@end
