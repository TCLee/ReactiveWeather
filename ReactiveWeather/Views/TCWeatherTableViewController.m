//
//  TCWeatherTableViewController.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/26/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherTableViewController.h"
#import "TCHourlyForecastCell.h"
#import "TCDailyForecastCell.h"
#import "TCWeatherViewModel.h"
#import "TCHourlyForecastViewModel.h"
#import "TCDailyForecastViewModel.h"
#import "TCWeather.h"

/**
 * The section index on the table view.
 */
#define TCTableSectionHourlyForecast 0
#define TCTableSectionDailyForecast  1

/**
 * The current screen's height.
 */
#define TCScreenHeight UIScreen.mainScreen.bounds.size.height

/**
 * The reuse identifier for the cell that will display a 
 * section's header.
 */
static NSString * const TCHeaderCellIdentifier = @"TCForecastHeaderCell";

@interface TCWeatherTableViewController ()

@property (nonatomic, weak) IBOutlet UILabel *temperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *maxMinTemperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *cityLabel;
@property (nonatomic, weak) IBOutlet UILabel *conditionsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconView;

@end

@implementation TCWeatherTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupView];
    [self bindCurrentWeatherCondition];
    [self bindHourlyForecasts];

    [self.viewModel.fetchWeatherCommand execute:nil];

    // Redirect any errors from the view model to be displayed
    // on an alert view.
    [self rac_liftSelector:@selector(presentError:)
               withSignals:self.viewModel.fetchWeatherCommand.errors, nil];
}

- (void)setupView
{
    // Make the table header view fill up the screen.
    CGRect tableHeaderBounds = self.tableView.tableHeaderView.bounds;
    tableHeaderBounds.size.height = TCScreenHeight;
    self.tableView.tableHeaderView.bounds = tableHeaderBounds;
}

- (void)bindCurrentWeatherCondition
{
    RAC(self.temperatureLabel, text) =
        [RACObserve(self.viewModel, currentWeather.temperature)
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
          [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:TCTableSectionHourlyForecast]
                        withRowAnimation:UITableViewRowAnimationFade];
      }];
}

/**
 * Shows the given @c NSError object's details on a @c UIAlertView.
 */
- (void)presentError:(NSError *)error
{
	NSLog(@"%@", error);

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                        message:error.localizedRecoverySuggestion
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
	[alertView show];
}

#pragma mark Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Our table view only has 2 sections:
    // Hourly Forecast and Daily Forecast.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // We’re using table cells for headers here instead of the built-in
    // section headers which have sticky-scrolling behavior.
    // We want the headers to scroll along with the content.
    return (section == TCTableSectionHourlyForecast ?
            self.viewModel.hourlyForecasts.count :
            self.viewModel.dailyForecasts.count) + 1; // Add one more cell for the header.
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The first row of each section represents the
    // header row of the section.
    if (0 == indexPath.row) {
        UITableViewCell *headerCell =
            [tableView dequeueReusableCellWithIdentifier:
             TCHeaderCellIdentifier];

        headerCell.textLabel.text =
            (TCTableSectionHourlyForecast == indexPath.section ?
             NSLocalizedString(@"Hourly Forecast", nil) :
             NSLocalizedString(@"Daily Forecast", nil));

        return headerCell;
    }

    // Hourly Forecast Section
    if (TCTableSectionHourlyForecast == indexPath.section) {
        TCHourlyForecastCell *hourlyForecastCell =
            [tableView dequeueReusableCellWithIdentifier:
             NSStringFromClass(TCHourlyForecastCell.class)];

        hourlyForecastCell.viewModel =
            self.viewModel.hourlyForecasts[indexPath.row];

        return hourlyForecastCell;
    }

    // Daily Forecast Section
    TCDailyForecastCell *dailyForecastCell =
        [tableView dequeueReusableCellWithIdentifier:
         NSStringFromClass(TCDailyForecastCell.class)];

    dailyForecastCell.viewModel =
        self.viewModel.dailyForecasts[indexPath.row];

    return dailyForecastCell;
}

#pragma mark Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Determine cell height based on screen
    return 44;
}

@end
