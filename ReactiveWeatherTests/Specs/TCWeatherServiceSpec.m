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
    TCFakeURLSession *(^fakeURLSession)(TCFakeURLSessionDataTaskBlock) = ^TCFakeURLSession *(TCFakeURLSessionDataTaskBlock block) {
        return [[TCFakeURLSession alloc] initWithDataTaskBlock:block];
    };

    /**
     * Returns a new fake @c NSURLSession object that sends the
     * contents of @c filename as the response data.
     */
    TCFakeURLSession *(^fakeURLSessionWithTestData)(NSString *) = ^TCFakeURLSession *(NSString *filename) {
        return fakeURLSession(^(NSURL *url, TCFakeURLSessionDataTaskCompletionHandler completionHandler) {
            NSURL *testFileURL = [[NSBundle bundleForClass:self.class] URLForResource:filename.stringByDeletingPathExtension withExtension:filename.pathExtension];
            expect(testFileURL).notTo.beNil();

            NSData *testData = [NSData dataWithContentsOfURL:testFileURL];
            expect(testData).notTo.beNil();

            completionHandler(testData, nil, nil);
        });
    };

    describe(@"current condition", ^{
        it(@"should return an initialized TCWeather object on success", ^{
            TCWeatherService *weatherService = [[TCWeatherService alloc] initWithSession:fakeURLSessionWithTestData(@"CurrentCondition.json")];

            __block TCWeather *currentCondition = nil;
            [[weatherService currentConditionForLocation:CLLocationCoordinate2DMake(100, 100)]
                subscribeNext:^(TCWeather *value) {
                    currentCondition = value;
                }];

            expect(currentCondition).notTo.beNil();
            expect(currentCondition.date).to.equal([NSDate dateWithTimeIntervalSince1970:1399445555]);
            expect(currentCondition.temperature).to.equal(@100);
            expect(currentCondition.tempLow).to.equal(@50);
            expect(currentCondition.tempHigh).to.equal(@200);
            expect(currentCondition.locationName).to.equal(@"London");
            expect(currentCondition.conditionDescription).to.equal(@"scattered clouds");
            expect(currentCondition.condition).to.equal(@"Clouds");
            expect(currentCondition.icon).to.equal(@"03d");
        });
    });

    describe(@"hourly forecasts", ^{
        fit(@"should return an NSArray of TCWeather objects on success", ^ {
            const NSUInteger expectedCount = 6;
            TCWeatherService *weatherService = [[TCWeatherService alloc] initWithSession:fakeURLSessionWithTestData(@"HourlyForecast.json")];
            RACSignal *hourlyForecastSignal = [weatherService hourlyForecastsForLocation:CLLocationCoordinate2DMake(100, 100) limitTo:expectedCount];

            BOOL success = NO;
            NSError *error = nil;
            NSArray *hourlyForecasts = [hourlyForecastSignal asynchronousFirstOrDefault:nil success:&success error:&error];

            expect(hourlyForecasts).notTo.beNil();
            expect(error).to.beNil();
            expect(success).to.beTruthy();

            expect(hourlyForecasts.count).to.equal(expectedCount);
            expect(hourlyForecasts.firstObject).to.beKindOf(TCWeather.class);

            TCWeather *firstForecast = hourlyForecasts.firstObject;
            expect(firstForecast.date).to.equal([NSDate dateWithTimeIntervalSince1970:1399442400]);
        });
    });

    describe(@"daily forecasts", ^{
        
    });

    it(@"should send an error event on failure", ^{
        TCWeatherService *weatherService = [[TCWeatherService alloc] initWithSession:fakeURLSession(^(NSURL *url, TCFakeURLSessionDataTaskCompletionHandler completionHandler) {
            NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
            completionHandler(nil, nil, error);
        })];

        __block NSError *error = nil;
        [[weatherService currentConditionForLocation:CLLocationCoordinate2DMake(100, 100)]
            subscribeError:^(NSError *theError) {
                error = theError;
            }];

        expect(error).notTo.beNil();
        expect(error.domain).to.equal(NSURLErrorDomain);
        expect(error.code).to.equal(NSURLErrorNotConnectedToInternet);
    });

    it(@"should cancel fetch when subscription is disposed", ^{
        TCFakeURLSession *fakeSession = fakeURLSession(^(NSURL *url, TCFakeURLSessionDataTaskCompletionHandler completionHandler) {
            // Never calls `completionHandler` block!
            // This is so that we can test the cancelling behavior.
        });
        TCFakeURLSessionDataTask *fakeTask = fakeSession.fakeDataTask;
        TCWeatherService *weatherService = [[TCWeatherService alloc] initWithSession:fakeSession];

        RACDisposable *disposable = [[weatherService currentConditionForLocation:CLLocationCoordinate2DMake(100, 100)] subscribeNext:^(id _) {}];
        [disposable dispose];

        expect(fakeTask.isCancelled).to.beTruthy();
    });

});

SpecEnd