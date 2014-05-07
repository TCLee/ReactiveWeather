//
//  TCWeatherServiceSpec.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/6/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherService.h"
#import "TCWeather.h"
#import "TCFakeURLSession.h"

SpecBegin(TCWeatherService)

describe(@"init with session", ^{
    it(@"should be caught by assert if session is nil", ^{
        expect(^{
            (void)[[TCWeatherService alloc] initWithSession:nil];
        }).to.raise(NSInternalInconsistencyException);
    });
});

describe(@"weather data", ^{
//    __block TCWeatherService *weatherService = nil;
//
//    beforeEach(^{
//        TCFakeURLSession *fakeSession = [[TCFakeURLSession alloc] init];
//        weatherService = [[TCWeatherService alloc] initWithSession:fakeSession];
//    });

    describe(@"fetch current condition", ^{
        it(@"should return an initialized TCWeather object on success", ^{
            TCFakeURLSession *fakeSession = [[TCFakeURLSession alloc] initWithDataTaskBlock:^(NSURL *url, TCFakeURLSessionDataTaskCompletionHandler completionHandler) {
                // TODO: Read JSON data from file.
                NSData *data = [NSData dataWithContentsOfURL:nil];
                expect(data).notTo.beNil();
                completionHandler(data, nil, nil);
            }];
            TCWeatherService *weatherService = [[TCWeatherService alloc] initWithSession:fakeSession];

            __block TCWeather *currentCondition = nil;
            [[weatherService currentConditionForLocation:CLLocationCoordinate2DMake(100, 100)]
                subscribeNext:^(TCWeather *value) {
                    currentCondition = value;
                }];

            expect(currentCondition).notTo.beNil();
            expect(currentCondition.date).to.equal(NSDate.date);
            expect(currentCondition.humidity).to.equal(@100);
            expect(currentCondition.temperature).to.equal(@100);
            expect(currentCondition.tempHigh).to.equal(@100);
            expect(currentCondition.tempLow).to.equal(@100);
            expect(currentCondition.locationName).to.equal(@"");
            expect(currentCondition.sunrise).to.equal(NSDate.date);
            expect(currentCondition.sunset).to.equal(NSDate.date);
            expect(currentCondition.conditionDescription).to.equal(@"");
            expect(currentCondition.condition).to.equal(@"");
            expect(currentCondition.windBearing).to.equal(@100);
            expect(currentCondition.windSpeed).to.equal(@100);
            expect(currentCondition.icon).to.equal(@"");
        });

        it(@"should send an error event on failure", ^{

        });
    });

    describe(@"hourly forecasts", ^{

    });

    describe(@"daily forecasts", ^{
        
    });
});

SpecEnd