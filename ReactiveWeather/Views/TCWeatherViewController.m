//
//  TCWeatherViewController.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/10/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherViewController.h"
#import "TCWeatherViewModel.h"
#import "TCWeather.h"

#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

/**
 * The section index on the table view.
 */
#define TableSectionHourlyForecast 0
#define TableSectionDailyForecast  1

@interface TCWeatherViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *blurredImageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UILabel *temperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *maxMinTemperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *cityLabel;
@property (nonatomic, weak) IBOutlet UILabel *conditionsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconView;

@property (nonatomic, assign) CGFloat screenHeight;

@end

@implementation TCWeatherViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Save the screen height. We'll need this later to page the weather
    // data by screen height.
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;

    // Add blur effect to background image. This will not take effect
    // until the user scrolls.
    [self.blurredImageView setImageToBlur:self.backgroundImageView.image
                               blurRadius:10.0f
                          completionBlock:nil];

    // Make the table header view fill up the screen.
    CGRect tableHeaderBounds = self.tableView.tableHeaderView.bounds;
    tableHeaderBounds.size.height = self.screenHeight;
    self.tableView.tableHeaderView.bounds = tableHeaderBounds;

    [self bindToViewModel];
    [self bindCurrentWeatherCondition];
//    [self bindHourlyForecasts];
}

#pragma mark - ReactiveCocoa Bindings

- (void)bindToViewModel
{
    [self.viewModel.fetchWeatherCommand execute:nil];

    // Redirect all errors from the view model to be displayed
    // on an alert view.
    [self rac_liftSelector:@selector(presentError:)
               withSignals:self.viewModel.fetchWeatherCommand.errors, nil];
}

- (void)bindCurrentWeatherCondition
{
    RAC(self.temperatureLabel, text) =
        [[RACObserve(self, viewModel.currentWeather.temperature) logAll]
         map:^(NSNumber *temperature) {
             return [NSString stringWithFormat:@"%.0f°", temperature.floatValue];
         }];

    RAC(self.cityLabel, text) =
        [RACObserve(self.viewModel, currentWeather.locationName)
         map:^(NSString *locationName) {
             return [locationName capitalizedString];
         }];

    RAC(self.conditionsLabel, text) =
        [RACObserve(self.viewModel, currentWeather.condition)
         map:^(NSString *condition) {
             return [condition capitalizedString];
         }];

    RAC(self.iconView, image) =
        [[RACObserve(self.viewModel, currentWeather.imageName)
          ignore:nil]
          map:^(NSString *imageName) {
              return [UIImage imageNamed:imageName];
          }];

    // Combine the max and min temperatures for display in a label.
    RAC(self.maxMinTemperatureLabel, text) =
        [[RACObserve(self.viewModel, currentWeather.tempHigh)
          combineLatestWith:RACObserve(self, viewModel.currentWeather.tempLow)]
          reduceEach:^(NSNumber *maxTemperature, NSNumber *minTemperature) {
              return [NSString stringWithFormat:@"%.0f° / %.0f°",
                      maxTemperature.floatValue, minTemperature.floatValue];
          }];
}

- (void)bindHourlyForecasts
{
    @weakify(self);

    [[RACObserve(self.viewModel, hourlyForecasts)
      distinctUntilChanged]
      subscribeNext:^(id _) {
          @strongify(self);
          [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:TableSectionHourlyForecast]
                        withRowAnimation:UITableViewRowAnimationFade];
      }];
}

/**
 * Shows the given @c NSError object's details on a @c UIAlertView.
 */
- (void)presentError:(NSError *)error
{
	NSLog(@"<%@>: %@", NSStringFromClass([self class]), error);

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                        message:error.localizedRecoverySuggestion
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
	[alertView show];
}

#pragma mark - UITableViewDataSource

// Our table view only has 2 sections: Hourly Forecast and Daily Forecast.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // We’re using table cells for headers here instead of the built-in
    // section headers which have sticky-scrolling behavior.
    // We want the headers to scroll along with the content.
    return (section == TableSectionHourlyForecast ?
            self.viewModel.hourlyForecasts.count :
            self.viewModel.dailyForecasts.count) + 1; // Add one more cell for the header.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier = @"TCWeatherCell";
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
    }

    // Forecast cells are not selectable.
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];

    // TODO: Setup the cell

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Determine cell height based on screen
    return 44;
}
@end
