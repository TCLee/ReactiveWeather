//
//  TCLocationServiceSpec.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/3/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

SPEC_BEGIN(TCLocationService)

describe(@"Math", ^{
    it(@"is pretty cool", ^{
        NSUInteger a = 16;
        NSUInteger b = 26;

        [[theValue(a + b) should] equal:theValue(42)];
    });
});

SPEC_END
