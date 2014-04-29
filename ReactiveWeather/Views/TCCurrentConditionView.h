//
//  TCCurrentConditionView.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/29/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@class TCCurrentConditionViewModel;

@interface TCCurrentConditionView : UIView

/**
 * The view model associated with this view.
 */
@property (nonatomic, strong) TCCurrentConditionViewModel *viewModel;

@end
