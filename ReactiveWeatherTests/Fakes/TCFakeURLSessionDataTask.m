//
//  TCFakeURLSessionDataTask.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/7/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCFakeURLSessionDataTask.h"

@implementation TCFakeURLSessionDataTask

- (instancetype)init
{
    self = [super init];
    if (nil == self) { return nil; }

    _resumed = NO;
    _cancelled = NO;
    
    return self;
}

- (void)resume
{
    _resumed = YES;
}

- (void)cancel
{
    _cancelled = YES;
}

@end
