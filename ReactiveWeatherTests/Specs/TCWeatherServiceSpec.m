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
    /**
     * Returns a new fake @c NSURLSession object. The @c 
     * dataTaskWithURL:completionHandler: method implementation will be 
     * replaced with the given @c block.
     */
    TCFakeURLSession *(^createFakeURLSession)(TCFakeURLSessionDataTaskBlock) = ^TCFakeURLSession *(TCFakeURLSessionDataTaskBlock block) {
        return [[TCFakeURLSession alloc] initWithDataTaskBlock:block];
    };

    /**
     * Returns a new fake @c NSURLSession object that sends the
     * contents of @c filename as the response data.
     */
    TCFakeURLSession *(^createFakeURLSessionWithTestData)(NSString *) = ^TCFakeURLSession *(NSString *filename) {
        return createFakeURLSession(^(NSURL *url, TCFakeURLSessionDataTaskCompletionHandler completionHandler) {
            NSURL *testFileURL = [[NSBundle bundleForClass:self.class] URLForResource:filename.stringByDeletingPathExtension withExtension:filename.pathExtension];
            expect(testFileURL).notTo.beNil();

            NSData *testData = [NSData dataWithContentsOfURL:testFileURL];
            expect(testData).notTo.beNil();

            completionHandler(testData, nil, nil);
        });
    };

    NSString * const TCWeatherServiceCancelAndErrorExamples = @"TCWeatherServiceCancelAndErrorExamples";
    NSString * const TCWeatherServiceCancelAndErrorExamplesCreateSignalBlock = @"TCWeatherServiceCancelAndErrorExamplesSignal";

    sharedExamplesFor(TCWeatherServiceCancelAndErrorExamples, ^(NSDictionary *data) {
        __block RACSignal *(^getSignal)(TCWeatherService *) = nil;

        beforeEach(^{
            getSignal = [data[TCWeatherServiceCancelAndErrorExamplesCreateSignalBlock] copy];
            expect(getSignal).notTo.beNil();
        });

        it(@"should send an error event on failure", ^{
            NSError *testError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];
            TCFakeURLSession *fakeSession = createFakeURLSession(^(NSURL *url, TCFakeURLSessionDataTaskCompletionHandler completionHandler) {
                completionHandler(nil, nil, testError);
            });
            TCWeatherService *weatherService = [[TCWeatherService alloc] initWithSession:fakeSession];

            BOOL success = YES;
            NSError *error = nil;
            RACSignal *signal = getSignal(weatherService);
            id result = [signal firstOrDefault:nil success:&success error:&error];

            expect(result).to.beNil();
            expect(success).to.beFalsy();
            expect(error).to.equal(testError);
        });

        it(@"should cancel fetch when subscription is disposed", ^{
            TCFakeURLSession *fakeSession = createFakeURLSession(^(NSURL *url, TCFakeURLSessionDataTaskCompletionHandler completionHandler) {
                // Never calls `completionHandler` block!
                // This is so that we can test the cancelling behavior.
            });
            TCFakeURLSessionDataTask *fakeTask = fakeSession.fakeDataTask;
            TCWeatherService *weatherService = [[TCWeatherService alloc] initWithSession:fakeSession];

            RACSignal *signal = getSignal(weatherService);
            RACDisposable *disposable = [signal subscribeCompleted:^{}];
            [disposable dispose];

            expect(fakeTask.isCancelled).to.beTruthy();
        });
    });

    describe(@"current condition", ^{
        it(@"should return an TCWeather object on success", ^{
            TCWeatherService *weatherService = [[TCWeatherService alloc] initWithSession:createFakeURLSessionWithTestData(@"CurrentCondition.json")];
            RACSignal *currentConditionSignal = [weatherService currentConditionForLocation:CLLocationCoordinate2DMake(100, 100)];

            BOOL success = NO;
            NSError *error = nil;
            TCWeather *currentCondition = [currentConditionSignal firstOrDefault:nil success:&success error:&error];

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
            TCWeatherServiceCancelAndErrorExamplesCreateSignalBlock: ^RACSignal *(TCWeatherService *weatherService) {
                return [weatherService currentConditionForLocation:CLLocationCoordinate2DMake(100, 100)];
            }
        });
    });

    describe(@"hourly forecasts", ^{
        it(@"should send an array of TCWeather objects on success", ^ {
            const NSUInteger forecastsLimit = 6;
            TCWeatherService *weatherService = [[TCWeatherService alloc] initWithSession:createFakeURLSessionWithTestData(@"HourlyForecast.json")];
            RACSignal *hourlyForecastsSignal = [weatherService hourlyForecastsForLocation:CLLocationCoordinate2DMake(100, 100) limitTo:forecastsLimit];

            BOOL success = NO;
            NSError *error = nil;
            NSArray *hourlyForecasts = [hourlyForecastsSignal firstOrDefault:nil success:&success error:&error];

            expect(error).to.beNil();
            expect(success).to.beTruthy();

            expect(hourlyForecasts).notTo.beNil();
            expect(hourlyForecasts.count).to.equal(forecastsLimit);

            TCWeather *firstForecast = hourlyForecasts.firstObject;
            expect(firstForecast).to.beKindOf(TCWeather.class);
            expect(firstForecast.date).to.equal([NSDate dateWithTimeIntervalSince1970:1399442400]);
            expect(firstForecast.temperature).to.equal(@283.95);
        });

        itShouldBehaveLike(TCWeatherServiceCancelAndErrorExamples, @{
            TCWeatherServiceCancelAndErrorExamplesCreateSignalBlock: ^RACSignal *(TCWeatherService *weatherService) {
                return [weatherService hourlyForecastsForLocation:CLLocationCoordinate2DMake(100, 100) limitTo:1];
            }
        });
    });

    describe(@"daily forecasts", ^{
        
    });
});

SpecEnd
