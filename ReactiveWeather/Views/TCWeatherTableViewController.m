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

#import <ReactiveCocoa/UIRefreshControl+RACCommandSupport.h>

/**
 * The section index on the table view.
 */
#define TCTableSectionHourlyForecast 0
#define TCTableSectionDailyForecast  1

@interface TCWeatherTableViewController ()

@property (nonatomic, weak) IBOutlet TCCurrentConditionView *currentConditionView;

@end

@implementation TCWeatherTableViewController

#pragma mark Initialize

- (void)viewDidLoad
{
    [super viewDidLoad];

    RAC(self, viewModel.active) = [self viewModelShouldBeActive];

    // Table header view should fill up the table view.
    // We cannot specify this using autolayout in Interface Builder,
    // so we use RAC to do so.
    RAC(self.tableView.tableHeaderView, bounds) = RACObserve(self.tableView, bounds);

    // Bind the refresh control to the fetch weather command.
    // The refresh control's state will be synchronized with the
    // command's state.
    self.refreshControl.rac_command = self.viewModel.fetchWeatherCommand;
    [self bindRefreshControl:self.refreshControl
                 inTableView:self.tableView
          toCommandExecuting:self.viewModel.fetchWeatherCommand.executing];

    // Bind the table view to the weather data.
    RAC(self.currentConditionView, viewModel) = RACObserve(self, viewModel.currentCondition);
    [self bindTableView:self.tableView toHourlyForecasts:RACObserve(self.viewModel, hourlyForecasts)];
    [self bindTableView:self.tableView toDailyForecasts:RACObserve(self.viewModel, dailyForecasts)];

    RAC(self.tableView, rowHeight) = [self rowHeightFromForecastCount];

    // Redirect any errors from the view model to be displayed
    // on an alert view.
    [self rac_liftSelector:@selector(presentError:)
               withSignals:self.viewModel.fetchWeatherCommand.errors, nil];
}

/**
 * Returns a signal of @c NSNumber BOOL values indicating whether the 
 * view model should be active or not.
 *
 * The view model will only perform work when it is active and automatically
 * cancels any ongoing work if it is inactive.
 */
- (RACSignal *)viewModelShouldBeActive
{
    RACSignal *viewIsVisible = [[RACSignal
        merge:@[
            [[self rac_signalForSelector:@selector(viewDidAppear:)]
             mapReplace:@YES],
            [[self rac_signalForSelector:@selector(viewWillDisappear:)]
             mapReplace:@NO]
        ]]
        setNameWithFormat:@"%@ -viewIsVisible", self];

    RACSignal *appIsActive = [[RACSignal
        merge:@[
            [[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil]
             mapReplace:@YES],
            [[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationWillResignActiveNotification object:nil]
             mapReplace:@NO]
        ]]
        setNameWithFormat:@"%@ -appIsActive", self];

    return [[[RACSignal
        combineLatest:@[viewIsVisible, appIsActive]]
        and]
        setNameWithFormat:@"%@ -viewModelShouldBeActive", self];
}

/**
 * Returns a signal of @c NSNumber values representing a table view's
 * row height. 
 *
 * The row height value allows all the forecasts in a section to fit 
 * on a screen.
 */
- (RACSignal *)rowHeightFromForecastCount
{
    const CGFloat tableHeight = self.tableView.bounds.size.height;
    static const CGFloat defaultRowHeight = 44;

    // Hourly Forecasts and Daily Forecasts will have the same count,
    // so we can use either one.
    return [[[RACObserve(self.viewModel, hourlyForecasts)
        ignore:nil]
        distinctUntilChanged]
        map:^(NSArray *forecasts) {
            NSUInteger rowCountIncludingHeader = forecasts.count + 1;
            return (forecasts.count > 0 ? @(tableHeight / rowCountIncludingHeader) : @(defaultRowHeight));
        }];
}

/**
 * Binds the @c UIRefreshControl in the @c UITableView to a @c RACCommand's 
 * `executing` signal.
 *
 * @param refreshControl The @c UIRefreshControl to bind to the `executing` 
 *                       signal.
 * @param tableView      The @c UITableView that is associated with 
 *                       `refreshControl`.
 * @param executing      The @c RACCommand's `executing` signal.
 */
- (void)bindRefreshControl:(UIRefreshControl *)refreshControl inTableView:(UITableView *)tableView toCommandExecuting:(RACSignal *)executing
{
    [[[executing
        skipWhileBlock:^BOOL(NSNumber *isExecuting) {
            // Ignore until we start fetching weather data.
            return !isExecuting.boolValue;
        }]
        distinctUntilChanged]
        subscribeNext:^(NSNumber *isExecuting) {
            if (isExecuting.boolValue) {
                [refreshControl beginRefreshing];
                [tableView setContentOffset:CGPointMake(0, -refreshControl.bounds.size.height) animated:YES];
            } else {
                [refreshControl endRefreshing];
                [tableView setContentOffset:CGPointZero animated:YES];
            }
        }];
}

/**
 * Binds `tableView` section to a signal of hourly forecast data.
 */
- (void)bindTableView:(UITableView *)tableView toHourlyForecasts:(RACSignal *)hourlyForecasts
{
    [[[hourlyForecasts
        ignore:nil]
        distinctUntilChanged]
        subscribeNext:^(id _) {
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:TCTableSectionHourlyForecast]
                     withRowAnimation:UITableViewRowAnimationFade];
        }];
}

/**
 * Binds `tableView` section to a signal of daily forecast data.
 */
- (void)bindTableView:(UITableView *)tableView toDailyForecasts:(RACSignal *)dailyForecasts
{
    [[[dailyForecasts
        ignore:nil]
        distinctUntilChanged]
        subscribeNext:^(id _) {
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:TCTableSectionDailyForecast]
                     withRowAnimation:UITableViewRowAnimationFade];
        }];
}

/**
 * Presents the given `error` on a @c UIAlertView.
 *
 * @param error The @c NSError object containing the error details.
 */
- (void)presentError:(NSError *)error
{
	NSLog(@"Error: %@", error);

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
    NSUInteger rowCount = (section == TCTableSectionHourlyForecast ?
                           self.viewModel.hourlyForecasts.count :
                           self.viewModel.dailyForecasts.count);

    // Add one more cell for the header.
    // We’re using table cells for headers here instead of the built-in
    // section headers which will stick to the top.
    return (rowCount > 0 ? rowCount + 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The first row of each section represents the header row of
    // that section.
    if (0 == indexPath.row) {
        static NSString * const TCHeaderCellIdentifier = @"TCForecastHeaderCell";

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

@end
