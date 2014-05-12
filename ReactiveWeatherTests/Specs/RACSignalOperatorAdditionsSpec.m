//
//  RACSignalOperatorAdditionsSpec.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "RACSignal+TCOperatorAdditions.h"

SpecBegin(RACSignalOperatorAdditions)

describe(@"-tc_mapEach:", ^{
    it(@"should map each element in the array", ^{
        RACSubject *inputSubject = [RACSubject subject];
        __block NSArray *mappedArray = nil;

        [[inputSubject
            tc_mapEach:^(NSNumber *number) {
                return [number stringValue];
            }]
            subscribeNext:^(id value) {
                expect(value).to.beKindOf(NSArray.class);
                mappedArray = [value copy];
            }];

        [inputSubject sendNext:@[ @1, @2, @3 ]];
        [inputSubject sendCompleted];

        expect(mappedArray).to.equal(@[ @"1", @"2", @"3" ]);
    });

    it(@"should assert signal value is an NSArray kind", ^{
        RACSubject *inputSubject = [RACSubject subject];
        
        [[inputSubject
            tc_mapEach:^(id value) {
                return value;
            }]
            subscribeCompleted:^{
                // Never called but we need to subscribe to the subject.
            }];

        expect(^{
            [inputSubject sendNext:@"an invalid value"];
        }).to.raise(NSInternalInconsistencyException);
    });
});

SpecEnd
