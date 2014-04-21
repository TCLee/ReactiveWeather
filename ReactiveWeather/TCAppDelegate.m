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
    TCWeatherViewController *weatherViewController =
        (TCWeatherViewController *) self.window.rootViewController;    
    weatherViewController.viewModel =
        [[TCWeatherViewModel alloc] initWithLocationService:[TCLocationService new]
                                             weatherService:[TCWeatherService new]];

    return YES;
}

@end
