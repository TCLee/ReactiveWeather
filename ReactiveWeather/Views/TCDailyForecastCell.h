//
//  TCDailyForecastCell.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@class TCDailyForecastViewModel;

/**
 * The table cell view used to display a daily weather forecast data.
 */
@interface TCDailyForecastCell : UITableViewCell

/**
 * The view model associated with this table cell view.
 */
@property (nonatomic, strong) TCDailyForecastViewModel *viewModel;

@end
