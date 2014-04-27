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

#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

static NSString * const TCChildSegueIdentifier = @"TCChildTableViewController";

@interface TCWeatherViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *blurredImageView;

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
    [self.blurredImageView setImageToBlur:self.backgroundImageView.image
                               blurRadius:10.0f
                          completionBlock:nil];
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
