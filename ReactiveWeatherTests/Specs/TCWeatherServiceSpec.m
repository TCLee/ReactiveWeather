//
//  TCWeatherServiceSpec.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/6/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherService.h"
#import "TCWeather.h"
#import "TCDailyForecast.h"
#import "TCFakeURLSession.h"
#import "TCFakeURLSessionDataTask.h"

SpecBegin(TCWeatherService)

describe(@"init with session", ^{
    it(@"should be caught by assert if session is nil", ^{
        expect(^{
            (void)[[TCWeatherService alloc] initWithSession:nil];
        }).to.raise(NSInternalInconsistencyException);
    });
});

describe(@"fetch weather data", ^{
    TCFakeURLSession * const fakeSession = [[TCFakeURLSession alloc] init];
    TCWeatherService * const weatherService = [[TCWeatherService alloc] initWithSession:fakeSession];

    /**
     * Returns a fake data task block that returns the response data from the 
     * given filename.
     */
    TCFakeURLSessionDataTaskBlock (^ const fakeDataTaskBlockWithResponse)(NSString *) = ^TCFakeURLSessionDataTaskBlock (NSString *filename) {
        return ^(__unused NSURL *url, TCFakeURLSessionDataTaskCompletionHandler completionHandler) {
            NSURL *testFileURL = [[NSBundle bundleForClass:self.class] URLForResource:filename.stringByDeletingPathExtension withExtension:filename.pathExtension];
            expect(testFileURL).notTo.beNil();

            NSData *testData = [NSData dataWithContentsOfURL:testFileURL];
            expect(testData).notTo.beNil();

            completionHandler(testData, nil, nil);
        };
    };

    NSString * const TCWeatherServiceCancelAndErrorExamples       = @"TCWeatherServiceCancelAndErrorExamples";
    NSString * const TCWeatherServiceCancelAndErrorExamplesSignal = @"TCWeatherServiceCancelAndErrorExamplesSignal";

    sharedExamplesFor(TCWeatherServiceCancelAndErrorExamples, ^(NSDictionary *data) {
        __block RACSignal *signal = nil;

        beforeEach(^{
            signal = data[TCWeatherServiceCancelAndErrorExamplesSignal];
            expect(signal).notTo.beNil();
        });

        it(@"should send an error event on failure", ^{
            NSError *testError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
            fakeSession.fakeDataTaskBlock = ^(__unused NSURL *url, TCFakeURLSessionDataTaskCompletionHandler completionHandler) {
                completionHandler(nil, nil, testError);
            };

            BOOL success = YES;
            NSError *error = nil;
            id result = [signal asynchronousFirstOrDefault:nil success:&success error:&error];

            expect(result).to.beNil();
            expect(success).to.beFalsy();
            expect(error).to.equal(testError);
        });

        it(@"should cancel fetch when subscription is disposed", ^{
            fakeSession.fakeDataTaskBlock = ^(__unused NSURL *url, __unused TCFakeURLSessionDataTaskCompletionHandler completionHandler) {
                // Never calls `completionHandler` block!
                // This is so that we can test the cancelling behavior.
            };

            RACDisposable *disposable = [signal subscribeCompleted:^{}];
            [disposable dispose];

            TCFakeURLSessionDataTask *fakeTask = fakeSession.fakeDataTask;
            expect(fakeTask.isCancelled).to.beTruthy();
        });
    });

    NSString * const TCWeatherServiceForecastExamples                                    = @"TCWeatherServiceForecastExamples";
    NSString * const TCWeatherServiceForecastExamplesResponseFilename                    = @"TCWeatherServiceForecastExamplesResponseFilename";
    NSString * const TCWeatherServiceForecastExamplesLimit                               = @"TCWeatherServiceForecastExamplesLimit";
    NSString * const TCWeatherServiceForecastExamplesSignal                              = @"TCWeatherServiceForecastExamplesSignal";
    NSString * const TCWeatherServiceForecastExamplesModelClass                          = @"TCWeatherServiceForecastExamplesModelClass";
    NSString * const TCWeatherServiceForecastExamplesFirstForecastExpectedDate           = @"TCWeatherServiceForecastExamplesFirstForecastExpectedDate";
    NSString * const TCWeatherServiceForecastExamplesFirstForecastExpectedTemperature    = @"TCWeatherServiceForecastExamplesFirstForecastExpectedTemperature";
    NSString * const TCWeatherServiceForecastExamplesFirstForecastExpectedMinTemperature = @"TCWeatherServiceForecastExamplesFirstForecastExpectedMinTemperature";
    NSString * const TCWeatherServiceForecastExamplesFirstForecastExpectedMaxTemperature = @"TCWeatherServiceForecastExamplesFirstForecastExpectedMaxTemperature";

    sharedExamplesFor(TCWeatherServiceForecastExamples, ^(NSDictionary *data) {
        it(@"should send an array of weather objects on success", ^{
            fakeSession.fakeDataTaskBlock = fakeDataTaskBlockWithResponse(data[TCWeatherServiceForecastExamplesResponseFilename]);

            RACSignal *forecastsSignal = data[TCWeatherServiceForecastExamplesSignal];

            BOOL success = NO;
            NSError *error = nil;
            NSArray *forecasts = [forecastsSignal asynchronousFirstOrDefault:nil success:&success error:&error];

            expect(success).to.beTruthy();
            expect(error).to.beNil();
            expect(forecasts).notTo.beNil();

            // Verify that the signal returned the correct number
            // of forecast objects.
            expect(forecasts.count).to.equal(data[TCWeatherServiceForecastExamplesLimit]);

            // Verify that the model objects are of the correct class.
            expect(forecasts.firstObject).to.beInstanceOf(data[TCWeatherServiceForecastExamplesModelClass]);

            TCWeather *firstForecast = forecasts.firstObject;
            expect(firstForecast.date).to.equal(data[TCWeatherServiceForecastExamplesFirstForecastExpectedDate]);
            expect(firstForecast.temperature).to.equal(data[TCWeatherServiceForecastExamplesFirstForecastExpectedTemperature]);
            expect(firstForecast.tempHigh).to.equal(data[TCWeatherServiceForecastExamplesFirstForecastExpectedMaxTemperature]);
            expect(firstForecast.tempLow).to.equal(data[TCWeatherServiceForecastExamplesFirstForecastExpectedMinTemperature]);
        });
    });

    describe(@"current condition", ^{
        it(@"should send an TCWeather object on success", ^{
            fakeSession.fakeDataTaskBlock = fakeDataTaskBlockWithResponse(@"CurrentCondition.json");

            RACSignal *currentConditionSignal = [weatherService currentConditionForLocation:CLLocationCoordinate2DMake(100, 100)];

            BOOL success = NO;
            NSError *error = nil;
            TCWeather *currentCondition = [currentConditionSignal asynchronousFirstOrDefault:nil success:&success error:&error];

            expect(currentCondition).notTo.beNil();
            expect(success).to.beTruthy();
            expect(error).to.beNil();

            expect(currentCondition.date).to.equal([NSDate dateWithTimeIntervalSince1970:1399445555]);
            expect(currentCondition.temperature).to.equal(@100);
            expect(currentCondition.tempLow).to.equal(@50);
            expect(currentCondition.tempHigh).to.equal(@200);
            expect(currentCondition.locationName).to.equal(@"London");
            expect(currentCondition.conditionDescription).to.equal(@"scattered clouds");
            expect(currentCondition.condition).to.equal(@"Clouds");
            expect(currentCondition.icon).to.equal(@"03d");
        });

        itShouldBehaveLike(TCWeatherServiceCancelAndErrorExamples, @{
            TCWeatherServiceCancelAndErrorExamplesSignal: [weatherService currentConditionForLocation:CLLocationCoordinate2DMake(100, 100)]
        });
    });

    describe(@"hourly forecasts", ^{
        itShouldBehaveLike(TCWeatherServiceForecastExamples, ^{
            const NSUInteger numberOfForecasts = 5;
            return @{
                TCWeatherServiceForecastExamplesResponseFilename: @"HourlyForecasts.json",
                TCWeatherServiceForecastExamplesLimit: @(numberOfForecasts),
                TCWeatherServiceForecastExamplesSignal: [weatherService hourlyForecastsForLocation:CLLocationCoordinate2DMake(100, 100) limitTo:numberOfForecasts],
                TCWeatherServiceForecastExamplesModelClass: TCWeather.class,
                TCWeatherServiceForecastExamplesFirstForecastExpectedDate: [NSDate dateWithTimeIntervalSince1970:1399788000],
                TCWeatherServiceForecastExamplesFirstForecastExpectedTemperature: @282.68,
                TCWeatherServiceForecastExamplesFirstForecastExpectedMinTemperature: @281.591,
                TCWeatherServiceForecastExamplesFirstForecastExpectedMaxTemperature: @282.68
            };
        });

        itShouldBehaveLike(TCWeatherServiceCancelAndErrorExamples, @{
            TCWeatherServiceCancelAndErrorExamplesSignal: [weatherService hourlyForecastsForLocation:CLLocationCoordinate2DMake(100, 100) limitTo:1]
        });
    });

    describe(@"daily forecasts", ^{
        itShouldBehaveLike(TCWeatherServiceForecastExamples, ^{
            const NSUInteger numberOfForecasts = 7;
            return @{
                TCWeatherServiceForecastExamplesResponseFilename: @"DailyForecasts.json",
                TCWeatherServiceForecastExamplesLimit: @(numberOfForecasts),
                TCWeatherServiceForecastExamplesSignal: [weatherService dailyForecastsForLocation:CLLocationCoordinate2DMake(100, 100) limitTo:numberOfForecasts],
                TCWeatherServiceForecastExamplesModelClass: TCDailyForecast.class,
                TCWeatherServiceForecastExamplesFirstForecastExpectedDate: [NSDate dateWithTimeIntervalSince1970:1399806000],
                TCWeatherServiceForecastExamplesFirstForecastExpectedMinTemperature: @283.01,
                TCWeatherServiceForecastExamplesFirstForecastExpectedMaxTemperature: @284.29
            };
        });

        itShouldBehaveLike(TCWeatherServiceCancelAndErrorExamples, @{
            TCWeatherServiceCancelAndErrorExamplesSignal:[weatherService dailyForecastsForLocation:CLLocationCoordinate2DMake(100, 100) limitTo:1]
        });
    });

    afterEach(^{
        fakeSession.fakeDataTaskBlock = nil;
    });
});

SpecEnd
