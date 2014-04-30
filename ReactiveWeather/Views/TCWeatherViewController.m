//
//  TCWeatherViewController.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/10/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherViewController.h"
#import "TCWeatherTableViewController.h"
#import "TCWeatherViewModel.h"

#import <FXBlurView/FXBlurView.h>

@interface TCWeatherViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet FXBlurView *blurFXView;

@end

@implementation TCWeatherViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.blurFXView.underlyingView = self.backgroundImageView;
    RAC(self.blurFXView, blurEnabled) = [self shouldEnableBlur];
    RAC(self.blurFXView, alpha) = [self verticalContentOffsetToAlpha];
}

#pragma mark Blur View Effect

/**
 * Returns a signal of @c NSNumber BOOL values indicating if the blur
 * effect should be enabled or not.
 */
- (RACSignal *)shouldEnableBlur
{
    return [[[RACObserve(self.blurFXView, alpha)
        distinctUntilChanged]
        map:^(NSNumber *alpha) {
            // Only enable blur effects if blur view's alpha has changed.
            return (alpha.floatValue > 0 ? @YES : @NO);
        }]
        startWith:@NO];
}

/**
 * Returns a signal of @c NSNumber values from @c 0.0 to @c 1.0
 * representing the alpha of a UIView.
 *
 * The alpha value is inversely proportional to the table view's content
 * offset's Y position. E.g. Scroll down to get alpha values towards
 * 1.0; scroll up to get alpha values towards 0.0.
 */
- (RACSignal *)verticalContentOffsetToAlpha
{
    TCWeatherTableViewController *childTableViewController = self.childViewControllers.firstObject;
    const CGFloat tableHeight = childTableViewController.tableView.bounds.size.height;

    return [[[RACObserve(childTableViewController, tableView.contentOffset)
        distinctUntilChanged]
        map:^(NSValue *contentOffset) {
            // Scrolling past the top of the table must not affect the
            // blur alpha.
            CGFloat scrollPosition = MAX(0, contentOffset.CGPointValue.y);

            // Alpha should not exceed 1.0
            return @(MIN(1, scrollPosition / tableHeight));
        }]
        startWith:@0];
}

#pragma mark Storyboard Segue

static NSString * const TCChildSegueIdentifier = @"TCChildTableViewController";

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:TCChildSegueIdentifier]) {
        // Pass the view model to the child table view controller.
        TCWeatherTableViewController *childTableViewController = segue.destinationViewController;
        childTableViewController.viewModel = self.viewModel;
    }
}

@end
