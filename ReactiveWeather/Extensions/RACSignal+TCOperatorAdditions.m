//
//  RACSignal+TCOperatorAdditions.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/24/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "RACSignal+TCOperatorAdditions.h"

@implementation RACSignal (TCOperatorAdditions)

- (RACSignal *)replayLastLazily
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

@end
