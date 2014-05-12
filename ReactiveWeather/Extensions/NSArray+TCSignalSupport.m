//
//  NSArray+TCSignalSupport.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "NSArray+TCSignalSupport.h"

@implementation NSArray (TCSignalSupport)

- (RACSignal *)rac_signal
{
    NSArray *collection = [self copy];

    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        for (id object in collection) {
            [subscriber sendNext:object];
        }

        [subscriber sendCompleted];
        
        return nil;
    }];
}

@end
