//
//  TCCurrentConditionViewModel.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/29/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@class TCWeather;

#import "RVMViewModel.h"

@interface TCCurrentConditionViewModel : RVMViewModel

@property (nonatomic, readonly, copy) NSString *cityName;
@property (nonatomic, readonly, copy) NSString *condition;
@property (nonatomic, readonly, copy) NSString *iconName;
@property (nonatomic, readonly, copy) NSNumber *currentTemperature;
@property (nonatomic, readonly, copy) NSNumber *minTemperature;
@property (nonatomic, readonly, copy) NSNumber *maxTemperature;

- (instancetype)initWithWeather:(TCWeather *)weather;

@end
