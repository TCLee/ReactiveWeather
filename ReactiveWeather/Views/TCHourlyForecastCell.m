//
//  TCHourlyForecastCell.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCHourlyForecastCell.h"
#import "TCHourlyForecastViewModel.h"

#import "NSDateFormatter+TCForecastFormattingAdditions.h"

@implementation TCHourlyForecastCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (nil == self) { return nil; }

    RAC(self, textLabel.text) =
        [RACObserve(self, viewModel.dateAndTime)
         map:^(NSDate *dateAndTime) {
             return [NSDateFormatter.sharedDateFormatter
                     forecastHourStringFromDate:dateAndTime];
         }];

    RAC(self, detailTextLabel.text) =
        [RACObserve(self, viewModel.temperature)
         map:^(NSNumber *temperature) {
             return [NSString stringWithFormat:@"%.0f°",
                     temperature.floatValue];
         }];

    return self;
}

@end
