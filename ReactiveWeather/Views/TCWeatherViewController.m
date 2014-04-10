//
//  TCWeatherViewController.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/10/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherViewController.h"

#import <TSMessages/TSMessage.h>
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface TCWeatherViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *blurredImageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, assign) CGFloat screenHeight;

@end

@implementation TCWeatherViewController

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
}

// Override to return a lighter status bar style.
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Views Setup

#pragma mark - UITableViewDataSource

// Our table view only has 2 sections: Hourly Forecast and Daily Forecast.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // TODO: Return count of forecast
    return 0;
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
