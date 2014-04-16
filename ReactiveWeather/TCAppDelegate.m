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

@implementation TCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    TCWeatherViewController *weatherViewController =
        (TCWeatherViewController *) self.window.rootViewController;    
    weatherViewController.viewModel = [[TCWeatherViewModel alloc] init];

    return YES;
}

@end
