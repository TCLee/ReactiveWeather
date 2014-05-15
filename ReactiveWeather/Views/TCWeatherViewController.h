//
//  TCWeatherViewController.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/10/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@class TCWeatherViewModel;

/**
 * This view controller is the parent of a child table view 
 * controller that will present the weather data. We need to do 
 * this because if we used a @c UITableViewController directly we 
 * will not be able to customize the view.
 *
 * It also manages the view that applies blur effects to a
 * background image.
 */
@interface TCWeatherViewController : UIViewController

/**
 * The view model for this view layer.
 */
@property (nonatomic, strong) TCWeatherViewModel *viewModel;

@end
