//
//  TCWeatherTableViewController.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/26/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherTableViewController.h"
#import "TCCurrentConditionView.h"
#import "TCHourlyForecastCell.h"
#import "TCDailyForecastCell.h"
#import "TCWeatherViewModel.h"
#import "TCCurrentConditionViewModel.h"
#import "TCHourlyForecastViewModel.h"
#import "TCDailyForecastViewModel.h"

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

@property (nonatomic, weak) IBOutlet TCCurrentConditionView *currentConditionView;

@end

@implementation TCWeatherTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupView];
    [self bindTableViewToForecasts];

    RAC(self.currentConditionView, viewModel) = RACObserve(self, viewModel.currentCondition);

    [self.viewModel.fetchWeatherCommand execute:nil];

    // Redirect any errors from the view model to be displayed
    // on an alert view.
    [self rac_liftSelector:@selector(presentError:)
               withSignals:self.viewModel.fetchWeatherCommand.errors, nil];


    const CGFloat tableHeight = self.tableView.bounds.size.height;
    static const CGFloat defaultRowHeight = 44;

    RAC(self.tableView, rowHeight) = [[[RACObserve(self.viewModel, hourlyForecasts)
        ignore:nil]
        distinctUntilChanged]
        map:^(NSArray *forecasts) {
            CGFloat rowCountIncludingHeader = forecasts.count + 1;
            return (forecasts.count > 0 ? @(tableHeight / rowCountIncludingHeader) : @(defaultRowHeight));
        }];
}

- (void)setupView
{
    // Make the table header view fill up the screen.
    CGRect tableHeaderBounds = self.tableView.tableHeaderView.bounds;
    tableHeaderBounds.size.height = TCScreenHeight;
    self.tableView.tableHeaderView.bounds = tableHeaderBounds;
}

- (void)bindTableViewToForecasts
{
    @weakify(self);

    // Hourly Forecasts
    [[RACObserve(self.viewModel, hourlyForecasts)
        distinctUntilChanged]
        subscribeNext:^(id _) {
            @strongify(self);
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:TCTableSectionHourlyForecast]
                          withRowAnimation:UITableViewRowAnimationFade];
        }];

    // Daily Forecasts
    [[RACObserve(self.viewModel, dailyForecasts)
        distinctUntilChanged]
        subscribeNext:^(id _) {
            @strongify(self);
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:TCTableSectionDailyForecast]
                          withRowAnimation:UITableViewRowAnimationFade];
        }];
}

/**
 * Shows the given @c NSError object's details on a @c UIAlertView.
 */
- (void)presentError:(NSError *)error
{
	NSLog(@"%@", error);

	UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:error.localizedDescription
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // We’re using table cells for headers here instead of the built-in
    // section headers which will stick to the top.
    return (section == TCTableSectionHourlyForecast ?
            self.viewModel.hourlyForecasts.count :
            self.viewModel.dailyForecasts.count) + 1; // Add one more cell for the header.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The first row of each section represents the header row of
    // that section.
    if (0 == indexPath.row) {
        UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:TCHeaderCellIdentifier];
        headerCell.textLabel.text = (TCTableSectionHourlyForecast == indexPath.section ?
                                     NSLocalizedString(@"Hourly Forecast", nil) :
                                     NSLocalizedString(@"Daily Forecast", nil));
        return headerCell;
    }

    // The index path `row` includes the section header row.
    // Our view model does not include the section header row, so minus 1.
    NSInteger dataRow = indexPath.row - 1;

    // Hourly Forecast Section
    if (TCTableSectionHourlyForecast == indexPath.section) {
        TCHourlyForecastCell *hourlyForecastCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TCHourlyForecastCell.class)];
        hourlyForecastCell.viewModel = self.viewModel.hourlyForecasts[dataRow];
        return hourlyForecastCell;
    }

    // Daily Forecast Section
    TCDailyForecastCell *dailyForecastCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TCDailyForecastCell.class)];
    dailyForecastCell.viewModel = self.viewModel.dailyForecasts[dataRow];
    return dailyForecastCell;
}

#pragma mark Table View Delegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // TODO: Determine cell height based on screen
//    return 44;
//}

@end
