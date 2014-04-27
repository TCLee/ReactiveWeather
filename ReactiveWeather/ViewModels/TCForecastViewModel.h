//
//  TCForecastViewModel.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>

@class TCWeather;

@interface TCForecastViewModel : RVMViewModel

@property (nonatomic, strong, readonly) TCWeather *weather;

- (instancetype)initWithForecast:(TCWeather *)weather;

@end
