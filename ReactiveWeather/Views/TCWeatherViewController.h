//
//  TCWeatherViewController.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/10/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@class TCWeatherViewModel;

/**
 * The view controller is responsible for presenting the weather data
 * to the user on its views.
 */
@interface TCWeatherViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

/**
 * The view model for this view layer.
 */
@property (nonatomic, strong) TCWeatherViewModel *viewModel;

@end
