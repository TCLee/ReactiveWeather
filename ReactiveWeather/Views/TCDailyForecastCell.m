//
//  TCDailyForecastCell.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCDailyForecastCell.h"
#import "TCDailyForecastViewModel.h"

#import "NSDateFormatter+TCForecastFormattingAdditions.h"

@implementation TCDailyForecastCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    RAC(self, textLabel.text) = [RACObserve(self, viewModel.date) map:^(NSDate *date) {
        return [NSDateFormatter.sharedDateFormatter forecastDayStringFromDate:date];
    }];

    RAC(self, detailTextLabel.text) =
        [RACSignal
         combineLatest:@[RACObserve(self, viewModel.minTemperature),
                         RACObserve(self, viewModel.maxTemperature)]
         reduce:^(NSNumber *minTemperature, NSNumber *maxTemperature) {
             return [NSString stringWithFormat:@"%.0f° / %.0f°",
                     minTemperature.floatValue, maxTemperature.floatValue];
         }];
}

@end
