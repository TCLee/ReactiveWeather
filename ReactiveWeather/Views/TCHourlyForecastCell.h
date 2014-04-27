//
//  TCHourlyForecastCell.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@class TCHourlyForecastViewModel;

/**
 * The table cell view used to display an hourly weather forecast data.
 */
@interface TCHourlyForecastCell : UITableViewCell

/**
 * The view model associated with this table cell view.
 */
@property (nonatomic, strong) TCHourlyForecastViewModel *viewModel;

@end
