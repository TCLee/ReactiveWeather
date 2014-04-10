//
//  TCAppDelegate.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/10/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCAppDelegate.h"
#import "TCWeatherViewController.h"

#import <TSMessages/TSMessage.h>

@implementation TCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//
//    // Set our custom view controller as the root view controller.
//    self.window.rootViewController = [[TCWeatherViewController alloc] init];
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
//
    // Make the root view controller the default view controller to display
    // the banner alerts on top.
    [TSMessage setDefaultViewController:self.window.rootViewController];

    return YES;
}

@end
