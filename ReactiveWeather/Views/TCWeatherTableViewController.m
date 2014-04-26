//
//  TCWeatherTableViewController.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/26/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherTableViewController.h"
#import "TCWeatherViewModel.h"
#import "TCWeather.h"

/**
 * The section index on the table view.
 */
#define TableSectionHourlyForecast 0
#define TableSectionDailyForecast  1

static NSString * const HeaderCellIdentifier = @"ForecastHeaderCell";
static NSString * const DataCellIdentifier = @"ForecastDataCell";

@interface TCWeatherTableViewController ()

@property (nonatomic, weak) IBOutlet UILabel *temperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *maxMinTemperatureLabel;
@property (nonatomic, weak) IBOutlet UILabel *cityLabel;
@property (nonatomic, weak) IBOutlet UILabel *conditionsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconView;

@end

@implementation TCWeatherTableViewController

#pragma mark Initialize

- (void)viewDidLoad
{
    [super viewDidLoad];    
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
    // section headers which have sticky-scrolling behavior.
    // We want the headers to scroll along with the content.
    return (section == TableSectionHourlyForecast ?
            self.viewModel.hourlyForecasts.count :
            self.viewModel.dailyForecasts.count) + 1; // Add one more cell for the header.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // First row will use the Header Prototype Cell.
    // Next rows will use the Data Prototype Cell.
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:
         (0 == indexPath.row ? HeaderCellIdentifier : DataCellIdentifier)];

    // TODO: Setup the cell

    return cell;
}

#pragma mark Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Determine cell height based on screen
    return 44;
}

@end
