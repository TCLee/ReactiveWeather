//
//  RACSignal+TCOperatorAdditions.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/24/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "RACSignal.h"

@interface RACSignal (TCOperatorAdditions)

/**
 * Multicasts the signal to a RACReplaySubject of capacity 1, and
 * lazily connects to the resulting RACMulticastConnection.
 *
 * @return The lazily connected, multicasted signal.
 *
 * @see replayLast
 * @see replayLazily
 */
- (RACSignal *)replayLastLazily;

@end
