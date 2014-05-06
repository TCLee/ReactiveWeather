//
//  TCLocationServiceSpec.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/3/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@import CoreLocation;

#import "TCLocationService.h"

SpecBegin(TCLocationService)

describe(@"init", ^{
    __block CLLocationManager *fakeLocationManager = nil;

    beforeEach(^{
        fakeLocationManager = mock(CLLocationManager.class);
    });

    it(@"should raise an exception if location manager is nil", ^{
        expect(^{
            __unused TCLocationService *locationService = [[TCLocationService alloc] initWithLocationManager:nil maxLocationAge:10];
        }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should raise an exception if max location age is 0", ^{
        expect(^{
            __unused TCLocationService *locationService = [[TCLocationService alloc] initWithLocationManager:fakeLocationManager maxLocationAge:0];
        }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should raise an exception if location manager delegate is already set", ^{
        expect(^{
            id<CLLocationManagerDelegate> fakeDelegate = mockProtocol(@protocol(CLLocationManagerDelegate));
            [given([fakeLocationManager delegate]) willReturn:fakeDelegate];

            __unused TCLocationService *locationService = [[TCLocationService alloc] initWithLocationManager:fakeLocationManager maxLocationAge:10];
        }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should set self as delegate of location manager", ^{
        __unused TCLocationService *locationService = [[TCLocationService alloc] initWithLocationManager:fakeLocationManager maxLocationAge:10];

        [MKTVerify(fakeLocationManager) setDelegate:locationService];
    });
});

describe(@"currentLocation", ^{
    __block TCLocationService *locationService = nil;
    __block CLLocationManager *fakeLocationManager = nil;

    const CLLocationAccuracy expectedAccuracy = kCLLocationAccuracyKilometer;
    const NSTimeInterval expectedAge = 15;

    beforeEach(^{
        fakeLocationManager = mock(CLLocationManager.class);
        fakeLocationManager.desiredAccuracy = expectedAccuracy;
        fakeLocationManager.distanceFilter = 1000;
        [given(fakeLocationManager.desiredAccuracy) willReturn:@(expectedAccuracy)];

        locationService = [[TCLocationService alloc] initWithLocationManager:fakeLocationManager maxLocationAge:expectedAge];
    });

    describe(@"automatically start and stop location services", ^{
        it(@"should start location services when there is one or more subscribers", ^{
            [[locationService currentLocation] subscribeNext:^(id _) {}];

            [MKTVerify(fakeLocationManager) startUpdatingLocation];
        });

        it(@"should stop location services when there is no subscriber", ^{
            RACDisposable *disposable = [[locationService currentLocation] subscribeNext:^(id _) {}];
            [disposable dispose];

            [MKTVerify(fakeLocationManager) stopUpdatingLocation];
        });
    });

    it(@"should send an error event on failure", ^{
        __block NSError *error = nil;
        [[locationService currentLocation] subscribeError:^(NSError *errorValue) {
            error = errorValue;
        }];

        NSError *testError = [[NSError alloc] initWithDomain:kCLErrorDomain code:kCLErrorNetwork userInfo:nil];
        [locationService locationManager:fakeLocationManager didFailWithError:testError];

        expect(error).notTo.beNil();
        expect(error.domain).to.equal(kCLErrorDomain);
        expect(error.code).to.equal(kCLErrorNetwork);
    });

    describe(@"acceptable location", ^{
        it(@"should send a location that matches the desired accuracy and age", ^{
            __block CLLocation *location = nil;
            [[locationService currentLocation] subscribeNext:^(CLLocation *value) {
                location = value;
            }];

            // Only `goodLocation` should be sent by the signal.
            CLLocation *goodLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 0) altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:NSDate.date];
            CLLocation *inaccurateLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 0) altitude:0 horizontalAccuracy:100000 verticalAccuracy:0 timestamp:NSDate.date];
            CLLocation *outdatedLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 0) altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate dateWithTimeIntervalSince1970:0]];
            [locationService locationManager:fakeLocationManager didUpdateLocations:@[goodLocation]];
            [locationService locationManager:fakeLocationManager didUpdateLocations:@[outdatedLocation]];
            [locationService locationManager:fakeLocationManager didUpdateLocations:@[inaccurateLocation]];

            expect(location).notTo.beNil();
            NSTimeInterval locationAge = fabs([location.timestamp timeIntervalSinceNow]);
            expect(locationAge).to.beLessThanOrEqualTo(expectedAge);
            expect(location.horizontalAccuracy).to.beLessThanOrEqualTo(expectedAccuracy);
        });

        static NSString * const TCNegativeAccuracyConstantExamples = @"TCNegativeAccuracyConstantExamples";
        static NSString * const TCDesiredAccuracyValue = @"TCDesiredAccuracyValue";

        sharedExamplesFor(TCNegativeAccuracyConstantExamples, ^(NSDictionary *data) {
            it(@"should handle accuracy constants with negative values", ^{
                expect(data[TCDesiredAccuracyValue]).notTo.beNil();
                [given(fakeLocationManager.desiredAccuracy) willReturn:data[TCDesiredAccuracyValue]];

                __block CLLocation *location = nil;
                [[locationService currentLocation] subscribeNext:^(CLLocation *value) {
                    location = value;
                }];

                CLLocationCoordinate2D testCoordinates = CLLocationCoordinate2DMake(100, 100);
                CLLocation *testLocation = [[CLLocation alloc] initWithCoordinate:testCoordinates altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:NSDate.date];
                [locationService locationManager:fakeLocationManager didUpdateLocations:@[testLocation]];

                expect(location).notTo.beNil();
                expect(location.coordinate).to.equal(testCoordinates);
            });
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
