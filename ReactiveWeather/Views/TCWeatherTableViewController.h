//
//  TCWeatherTableViewController.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/26/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@class TCWeatherViewModel;

@interface TCWeatherTableViewController : UITableViewController

/**
 * The view model for this view layer.
 */
@property (nonatomic, strong) TCWeatherViewModel *viewModel;

@end
