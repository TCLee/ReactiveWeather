//
//  TCAppDelegate.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/10/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCAppDelegate.h"

#import "TCWeatherViewController.h"
#import "TCWeatherViewModel.h"
#import "TCLocationService.h"
#import "TCWeatherService.h"

@implementation TCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create the view model with its service classes.
    TCLocationService *locationService =
        [[TCLocationService alloc] initWithAccuracy:kCLLocationAccuracyKilometer
                                     distanceFilter:1000.0f
                                        maxCacheAge:15.0f];
    TCWeatherService *weatherService = [[TCWeatherService alloc] init];
    TCWeatherViewModel *viewModel =
        [[TCWeatherViewModel alloc] initWithLocationService:locationService
                                             weatherService:weatherService];

    // Pass the view model to the view layer (view controller + view).
    TCWeatherViewController *viewController =
        (TCWeatherViewController *) self.window.rootViewController;
    viewController.viewModel = viewModel;

    return YES;
}

@end
