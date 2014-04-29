//
//  CLLocation+TCDebugAdditions.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/29/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "CLLocation+TCDebugAdditions.h"

NSString *tc_NSStringFromCoordinate(CLLocationCoordinate2D coordinate)
{
    return [NSString stringWithFormat:@"%f, %f",
            coordinate.latitude, coordinate.longitude];
}

@implementation CLLocation (TCDebugAdditions)

@end
