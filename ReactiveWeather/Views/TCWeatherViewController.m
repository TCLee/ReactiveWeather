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

static NSString * const TCChildSegueIdentifier = @"TCChildTableViewController";

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

    // Add blur effect to background image. This will not take effect
    // until the user scrolls.
    self.blurFXView.underlyingView = self.backgroundImageView;
    self.blurFXView.dynamic = NO;
    self.blurFXView.blurRadius = 20;
    self.blurFXView.tintColor = nil;
    self.blurFXView.blurEnabled = NO;
    self.blurFXView.alpha = 0;

    TCWeatherTableViewController *childTableViewController = self.childViewControllers.firstObject;
    const CGFloat tableHeight = childTableViewController.tableView.bounds.size.height;

    // When user scrolls down, the background image will be blurred.
    // Alternatively, when user scrolls back up the background image will
    // be clear again.

    RAC(self.blurFXView, blurEnabled) = [[[RACObserve(self.blurFXView, alpha)
        distinctUntilChanged]
        map:^(NSNumber *alpha) {
            NSLog(@"Alpha = %.2f", alpha.floatValue);
            return (alpha.floatValue > 0 ? @YES : @NO);
        }]
        startWith:@NO];

    RAC(self.blurFXView, alpha) = [[[RACObserve(childTableViewController, tableView.contentOffset)
        distinctUntilChanged]
        map:^(NSValue *contentOffset) {
            NSLog(@"Scroll Position = %.2f", contentOffset.CGPointValue.y);
            // Scrolling past the top of the table must not affect the
            // blur alpha.
            CGFloat scrollPosition = MAX(0, contentOffset.CGPointValue.y);

            // Alpha should not exceed 1.0
            return @(MIN(1, scrollPosition / tableHeight));
        }]
        startWith:@0];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:TCChildSegueIdentifier]) {
        // Pass the view model to the child table view controller.
        TCWeatherTableViewController *childTableViewController =
            segue.destinationViewController;
        childTableViewController.viewModel = self.viewModel;
    }
}

@end
