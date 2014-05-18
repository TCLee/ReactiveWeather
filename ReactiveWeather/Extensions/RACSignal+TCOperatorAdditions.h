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
 *              element and returns a new transformed element.
 *
 * @return A new signal of array values where each array's elements 
 *         have been transformed by @c block.
 */
- (instancetype)tc_mapEach:(id (^)(id value))block;

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

/**
 * Returns a signal that will have at most one subscription to the receiver at
 * any time. When the returned signal gets its first subscriber, the underlying
 * signal is subscribed to. When the returned signal has no subscribers, the
 * underlying subscription is disposed. Whenever an underlying subscription is
 * already open, new subscribers to the returned signal will receive all events
 * sent so far.
 *
 * @note
 * This operator is a backport of @c shareWhileActive method in 
 * @c ReactiveCocoa@3.0-development branch. Therefore, this method 
 * will be removed when RAC 3.0 is released.
 */
- (RACSignal *)tc_shareWhileActive;

@end
