//
//  TCWeatherTableViewController.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/26/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@class TCWeatherViewModel;

/**
 * This table view controller is a child view controller of the
 * main view controller @c TCWeatherViewController.
 *
 * We could not use the @c UITableViewController class directly because 
 * we needed to add the blurred view underneath the table view, which
 * @c UITableViewController does not allow.
 */
@interface TCWeatherTableViewController : UITableViewController

/**
 * A signal that sends a @c UITableView when the user scrolls the 
 * table view.
 */
@property (nonatomic, strong, readonly) RACSignal *tableViewDidScroll;

/**
 * The view model for this view layer.
 */
@property (nonatomic, strong) TCWeatherViewModel *viewModel;

@end
