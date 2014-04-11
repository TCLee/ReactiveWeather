//
//  TCDailyForecast.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/11/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCDailyForecast.h"

@implementation TCDailyForecast

// Daily Forecast uses different JSON keys for the
// min and max temperatures, so we will have to overwrite
// only these mappings.
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return [[super JSONKeyPathsByPropertyKey]
            mtl_dictionaryByAddingEntriesFromDictionary:
            @{@"tempHigh": @"temp.max",
              @"tempLow": @"temp.min"}];
}

@end
