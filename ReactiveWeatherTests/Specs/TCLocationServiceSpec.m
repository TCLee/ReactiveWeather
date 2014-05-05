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

    it(@"should raise an exception if location manager delegate is set", ^{
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
        [given([fakeLocationManager desiredAccuracy]) willReturnDouble:expectedAccuracy];

        locationService = [[TCLocationService alloc] initWithLocationManager:fakeLocationManager maxLocationAge:expectedAge];
    });

    it(@"should start location services when there is one or more subscribers", ^{
        [[locationService currentLocation] subscribeNext:^(id _) {}];

        [MKTVerify(fakeLocationManager) startUpdatingLocation];
    });

    it(@"should stop location services when there is no subscriber", ^{
        RACDisposable *disposable = [[locationService currentLocation] subscribeNext:^(id _) {}];
        [disposable dispose];

        [MKTVerify(fakeLocationManager) stopUpdatingLocation];
    });

    fit(@"should return a location that matches the accuracy and age", ^{
        __block CLLocation *location = nil;
        [[locationService currentLocation]
            subscribeNext:^(CLLocation *value) {
                location = value;
            }];

        // Verify that only `goodLocation` should be sent by the signal.
        CLLocation *inaccurateLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 0) altitude:0 horizontalAccuracy:100000 verticalAccuracy:0 timestamp:NSDate.date];
        CLLocation *outdatedLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 0) altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate dateWithTimeIntervalSince1970:0]];
        CLLocation *goodLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(0, 0) altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:NSDate.date];
        [locationService locationManager:fakeLocationManager didUpdateLocations:@[outdatedLocation]];
        [locationService locationManager:fakeLocationManager didUpdateLocations:@[inaccurateLocation]];
        [locationService locationManager:fakeLocationManager didUpdateLocations:@[goodLocation]];

        expect(location).toNot.beNil();
        NSTimeInterval locationAge = fabs([location.timestamp timeIntervalSinceNow]);
        expect(locationAge).to.beLessThanOrEqualTo(expectedAge);
        expect(location.horizontalAccuracy).to.beLessThanOrEqualTo(expectedAccuracy);
    });
});

SpecEnd
