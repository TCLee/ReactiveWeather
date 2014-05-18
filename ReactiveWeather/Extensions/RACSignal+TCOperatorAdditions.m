//
//  RACSignal+TCOperatorAdditions.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/24/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "RACSignal+TCOperatorAdditions.h"
#import "NSArray+TCSignalSupport.h"

@implementation RACSignal (TCOperatorAdditions)

- (RACSignal *)tc_replayLastLazily
{
    RACMulticastConnection *connection =
        [self multicast:[RACReplaySubject replaySubjectWithCapacity:1]];

    return [[RACSignal
             defer:^{
                 [connection connect];
                 return connection.signal;
             }]
             setNameWithFormat:@"[%@] -replayLastLazily", self.name];
}

- (instancetype)tc_mapEach:(id (^)(id value))block
{
    NSParameterAssert(block != nil);

    return [[self flattenMap:^(NSArray *value) {
        NSAssert([value isKindOfClass:NSArray.class],
                 @"-tc_mapEach: only works with an array value.");
        
        return [[value.rac_signal map:block] collect];
    }]
    setNameWithFormat:@"[%@] -tc_mapEach:", self.name];
}

// Code is taken from ReactiveCocoa/3.0-development branch.
- (RACSignal *)tc_shareWhileActive
{
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
	lock.name = @"com.tclee.ReactiveWeather.tc_shareWhileActive";

	// These should only be used while `lock` is held.
	__block NSUInteger subscriberCount = 0;
	__block RACDisposable *underlyingDisposable = nil;
	__block RACReplaySubject *inflightSubscription = nil;

    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        [lock lock];
        @onExit {
            [lock unlock];
        };

        if (++subscriberCount == 1) {
            // First subscriber, so subscribe to the underlying signal.
            inflightSubscription = [RACReplaySubject subject];
            underlyingDisposable = [self subscribe:inflightSubscription];
        }

        // [Subscribers 1..n] -> [RACReplaySubject] -> [RACSignal]
        [inflightSubscription subscribe:subscriber];

        return [RACDisposable disposableWithBlock:^{
            [lock lock];
            @onExit {
                [lock unlock];
            };

            NSCAssert(subscriberCount > 0, @"Mismatched decrement of subscriber count (%lu)", (unsigned long)subscriberCount);
            if (--subscriberCount == 0) {
                // Last subscriber, so dispose of the underlying
                // subscription.
                [underlyingDisposable dispose];
                underlyingDisposable = nil;
            }
        }];
    }] setNameWithFormat:@"[%@] -tc_shareWhileActive", self.name];
}

@end
