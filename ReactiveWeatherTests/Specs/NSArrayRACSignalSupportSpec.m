//
//  NSArrayRACSignalSupportSpec.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "NSArray+TCSignalSupport.h"

SpecBegin(NSArrayRACSignalSupport)

describe(@"NSArray.rac_signal", ^{
    it(@"should be able to convert array to and from a signal", ^{
        NSArray *array = @[ @1, @2, @3 ];
        RACSignal *signalFromArray = array.rac_signal;

        expect([signalFromArray toArray]).to.equal(array);
    });
});

SpecEnd