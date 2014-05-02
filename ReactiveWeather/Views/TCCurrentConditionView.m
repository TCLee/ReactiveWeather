//
//  TCCurrentConditionView.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/29/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCCurrentConditionView.h"
#import "TCCurrentConditionViewModel.h"

@interface TCCurrentConditionView ()

@property (nonatomic, weak) IBOutlet UILabel *temperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *maxMinTemperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *cityLabel;
@property (nonatomic, weak) IBOutlet UILabel *conditionsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconView;

@end

@implementation TCCurrentConditionView

- (void)awakeFromNib
{
    [super awakeFromNib];

    RAC(self.temperatureLabel, text) = [RACObserve(self, viewModel.currentTemperature) map:^(NSNumber *temperature) {
        return [NSString stringWithFormat:@"%.0f°", temperature.floatValue];
    }];

    RAC(self.cityLabel, text) = [RACObserve(self, viewModel.cityName) map:^(NSString *locationName) {
        return [locationName capitalizedString];
    }];

    RAC(self.conditionsLabel, text) = [RACObserve(self, viewModel.condition) map:^(NSString *condition) {
        return [condition capitalizedString];
    }];

    RAC(self.iconView, image) = [[RACObserve(self, viewModel.iconName)
        ignore:nil]
        map:^(NSString *imageName) {
            return [UIImage imageNamed:imageName];
        }];

    RAC(self.maxMinTemperatureLabel, text) = [RACSignal
        combineLatest:@[
            RACObserve(self, viewModel.minTemperature),
            RACObserve(self, viewModel.maxTemperature)
        ]
        reduce:^(NSNumber *minTemperature, NSNumber *maxTemperature) {
            return [NSString stringWithFormat:@"%.0f° / %.0f°", minTemperature.floatValue, maxTemperature.floatValue];
        }];
}

@end
