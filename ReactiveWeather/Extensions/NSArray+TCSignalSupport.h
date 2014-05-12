//
//  NSArray+TCSignalSupport.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

/**
 * Adds support to create a RACSignal directly from an NSArray.
 *
 * Instead of first creating a RACSequence and then converting 
 * it to a RACSignal. (i.e. NSArray -> RACSequence -> RACSignal)
 *
 * This category will be removed in RAC 3.0 (when it is released) as this 
 * feature is already provided there.
 */
@interface NSArray (TCSignalSupport)

/**
 * A signal that will send all of the objects in the collection.
 *
 * Mutating the collection will not affect the signal after it's been created.
 */
@property (nonatomic, strong, readonly) RACSignal *rac_signal;

@end
