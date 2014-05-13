//
//  TCFakeLocationService.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/13/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCFakeLocationService.h"

@implementation TCFakeLocationService

- (instancetype)init
{
    self = [super init];
    if (nil == self) { return nil; }

    _fakeLocation = [[CLLocation alloc] initWithLatitude:100 longitude:100];

    return self;
}

- (RACSignal *)currentLocation
{
    return [RACSignal return:self.fakeLocation];
}

@end
