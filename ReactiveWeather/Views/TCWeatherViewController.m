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
}

#pragma mark Storyboard Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // The child table view controller has been created when the
    // `prepareForSegue:` method is called.
    if ([segue.identifier isEqualToString:NSStringFromClass(TCWeatherTableViewController.class)] &&
        segue.sourceViewController == self) {

        // Pass the view model to the child table view controller.
        TCWeatherTableViewController *childTableViewController = segue.destinationViewController;
        childTableViewController.viewModel = self.viewModel;

        // Bind the blur effect to the child's table view scrolling.
        // E.g. Scrolling towards the bottom will blur the background image,
        //      scrolling back towards the top will make it clear again.
        RAC(self.blurFXView, alpha) = [self alphaFromTableViewDidScrollSignal:childTableViewController.tableViewDidScroll];
    }
}

/**
 * Returns a signal of alpha values mapped from the table view's content offset.
 *
 * @param tableViewDidScroll A signal that sends @c next each time the 
 *                           table view is scrolled.
 */
- (RACSignal *)alphaFromTableViewDidScrollSignal:(RACSignal *)tableViewDidScroll
{
    return [tableViewDidScroll
        map:^(UITableView *tableView) {
            // Scrolling past the top of the table (negative offset)
            // must not affect the blur alpha.
            CGFloat scrollPosition = MAX(0, tableView.contentOffset.y);
            CGFloat tableHeight = tableView.bounds.size.height;

            // Alpha should not exceed 1.0
            // (even if it does exceed UIKit doesn't seem to care)
            return @(MIN(1, scrollPosition / tableHeight));
        }];
}

@end
