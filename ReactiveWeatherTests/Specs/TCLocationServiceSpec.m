//
//  TCLocationServiceSpec.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/3/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

#import "TCLocationService.h"
#import "TCFakeLocationManager.h"
#import "TCFakeLocationManagerDelegate.h"

SpecBegin(TCLocationService)

describe(@"init", ^{
    it(@"should raise an exception if location manager is nil", ^{
        expect(^{
            (void)[[TCLocationService alloc] initWithLocationManager:nil maxLocationAge:10];
        }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should raise an exception if max location age is 0", ^{
        expect(^{
            (void)[[TCLocationService alloc] initWithLocationManager:TCFakeLocationManager.new maxLocationAge:0];
        }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should give warning if location manager delegate is already set", ^{
        expect(^{
            TCFakeLocationManager *fakeLocationManager = [[TCFakeLocationManager alloc] init];

            // Create the fake delegate and store it in a variable, so that it
            // does not get deallocated before this test case completes.
            TCFakeLocationManagerDelegate *fakeDelegate = [[TCFakeLocationManagerDelegate alloc] init];
            fakeLocationManager.delegate = fakeDelegate;

            (void)[[TCLocationService alloc] initWithLocationManager:fakeLocationManager maxLocationAge:10];
        }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should set location service as delegate of location manager", ^{
        TCFakeLocationManager *fakeLocationManager = [[TCFakeLocationManager alloc] init];
        TCLocationService *locationService = [[TCLocationService alloc] initWithLocationManager:fakeLocationManager maxLocationAge:10];

        expect(fakeLocationManager.delegate).to.equal(locationService);
    });
});

describe(@"get current location", ^{
    __block TCLocationService *locationService = nil;
    __block TCFakeLocationManager *fakeLocationManager = nil;
    __block RACSignal *currentLocationSignal = nil;

    const CLLocationAccuracy expectedAccuracy = kCLLocationAccuracyKilometer;
    const NSTimeInterval expectedAge = 15;

    beforeEach(^{
        fakeLocationManager = [[TCFakeLocationManager alloc] init];
        fakeLocationManager.desiredAccuracy = expectedAccuracy;
        fakeLocationManager.distanceFilter = 1000;

        locationService = [[TCLocationService alloc] initWithLocationManager:fakeLocationManager maxLocationAge:expectedAge];
        currentLocationSignal = [locationService currentLocation];
    });

    describe(@"automatically start and stop location services", ^{
        it(@"should start updating location once even if there are multiple subscribers", ^{
            [currentLocationSignal subscribeCompleted:^{}];
            [currentLocationSignal subscribeCompleted:^{}];
            [currentLocationSignal subscribeCompleted:^{}];

            expect(fakeLocationManager.numberOfLocationUpdatesInProgress).to.equal(1);
        });

        it(@"should not stop location updates when there is still at least one subscriber", ^{
            RACDisposable *firstDisposable  = [currentLocationSignal subscribeCompleted:^{}];
            RACDisposable *secondDisposable = [currentLocationSignal subscribeCompleted:^{}];
            [currentLocationSignal subscribeCompleted:^{}];

            [firstDisposable dispose];
            [secondDisposable dispose];

            expect(fakeLocationManager.numberOfLocationUpdatesInProgress).to.equal(1);
        });

        it(@"should stop location services when there is no subscriber", ^{
            RACDisposable *disposable = [[locationService currentLocation] subscribeCompleted:^{}];
            [disposable dispose];

            expect(fakeLocationManager.numberOfLocationUpdatesInProgress).to.equal(0);
        });
    });

    it(@"should send an error event on failure", ^{
        __block NSError *error = nil;
        [[locationService currentLocation] subscribeError:^(NSError *errorValue) {
            error = errorValue;
        }];

        NSError *testError = [[NSError alloc] initWithDomain:kCLErrorDomain code:kCLErrorNetwork userInfo:nil];
        [locationService locationManager:fakeLocationManager didFailWithError:testError];

        expect(error).to.equal(testError);
    });

    describe(@"location accuracy and age", ^{
        static NSString * const TCNegativeAccuracyConstantExamples = @"TCNegativeAccuracyConstantExamples";
        static NSString * const TCDesiredAccuracyValue = @"TCDesiredAccuracyValue";

        sharedExamplesFor(TCNegativeAccuracyConstantExamples, ^(NSDictionary *data) {
            it(@"should handle accuracy constants with negative values", ^{
                expect(data[TCDesiredAccuracyValue]).notTo.beNil();

                __block CLLocation *location = nil;
                [[locationService currentLocation] subscribeNext:^(CLLocation *value) {
                    location = value;
                }];

                CLLocation *testLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(100, 100) altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:NSDate.date];
                [locationService locationManager:fakeLocationManager didUpdateLocations:@[ testLocation ]];

                expect(location).to.equal(testLocation);
            });
        });

        it(@"should send a location that matches the desired accuracy and age", ^{
            __block CLLocation *location = nil;
            [[locationService currentLocation] subscribeNext:^(CLLocation *value) {
                location = value;
            }];

            // Expect only `goodLocation` should be sent by the signal.
            CLLocation *goodLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 0) altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:NSDate.date];
            CLLocation *inaccurateLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 0) altitude:0 horizontalAccuracy:100000 verticalAccuracy:0 timestamp:NSDate.date];
            CLLocation *outdatedLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 0) altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate dateWithTimeIntervalSince1970:0]];
            [locationService locationManager:fakeLocationManager didUpdateLocations:@[ goodLocation ]];
            [locationService locationManager:fakeLocationManager didUpdateLocations:@[ outdatedLocation ]];
            [locationService locationManager:fakeLocationManager didUpdateLocations:@[ inaccurateLocation ]];

            expect(location).notTo.beNil();
            NSTimeInterval locationAge = fabs([location.timestamp timeIntervalSinceNow]);
            expect(locationAge).to.beLessThanOrEqualTo(expectedAge);
            expect(location.horizontalAccuracy).to.beLessThanOrEqualTo(expectedAccuracy);
        });

        itShouldBehaveLike(TCNegativeAccuracyConstantExamples, @{
            TCDesiredAccuracyValue: @(kCLLocationAccuracyBestForNavigation)
        });

        itShouldBehaveLike(TCNegativeAccuracyConstantExamples, @{
            TCDesiredAccuracyValue: @(kCLLocationAccuracyBest)
        });
    });
});

SpecEnd
