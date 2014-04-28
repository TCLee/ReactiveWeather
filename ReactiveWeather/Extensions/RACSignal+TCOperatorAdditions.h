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
 * Maps @c block over each element of an array value in the receiver.
 *
 * The receiver @b must be a signal of array values.
 *
 * @param block The block receives one argument which is the array's
 *              element and returns a new transformed value.
 *
 * @return A new signal of array values where the array's elements 
 *         have been transformed by @c block.
 */
- (instancetype)tc_mapArray:(id (^)(id value))block;

/**
 * Multicasts the signal to a RACReplaySubject of capacity 1, and
 * lazily connects to the resulting RACMulticastConnection.
 *
 * @return The lazily connected, multicasted signal.
 *
 * @see replayLast
 * @see replayLazily
 */
- (RACSignal *)tc_replayLastLazily;

@end
