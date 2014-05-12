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

@end
