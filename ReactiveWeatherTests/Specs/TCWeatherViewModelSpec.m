//
//  TCWeatherViewModelSpec.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherViewModel.h"
#import "TCCurrentConditionViewModel.h"
#import "TCHourlyForecastViewModel.h"
#import "TCDailyForecastViewModel.h"
#import "TCFakeLocationService.h"
#import "TCFakeWeatherService.h"

#import "NSArray+TCSignalSupport.h"

SpecBegin(TCWeatherViewModel)

__block TCFakeLocationService *fakeLocationService = nil;
__block TCFakeWeatherService *fakeWeatherService = nil;

beforeAll(^{
    fakeLocationService = [[TCFakeLocationService alloc] init];
    fakeWeatherService = [[TCFakeWeatherService alloc] init];
});

describe(@"init", ^{
    it(@"should assert that location service is not nil", ^{
        expect(^{
            (void)[[TCWeatherViewModel alloc]
                   initWithLocationService:nil
                   weatherService:fakeWeatherService
                   hourlyForecastLimit:1
                   dailyForecastLimit:1];
        }).to.raise(NSInternalInconsistencyException);
    });

    it(@"should assert that weather service is not nil", ^{
        expect(^{
            (void)[[TCWeatherViewModel alloc]
                   initWithLocationService:fakeLocationService
                   weatherService:nil
                   hourlyForecastLimit:1
                   dailyForecastLimit:1];
        }).to.raise(NSInternalInconsistencyException);
    });
});

describe(@"fetch weather command", ^{
    /**
     * Maps @c block over each element in @c inputArray and returns the 
     * result array.
     */
    NSArray *(^ const mapArray)(NSArray *, id (^)(id)) = ^(NSArray *inputArray, id (^block)(id value)) {
        return [[inputArray.rac_signal map:block] toArray];
    };

    __block TCCurrentConditionViewModel *expectedCurrentCondition = nil;
    __block NSArray *expectedHourlyForecasts = nil;
    __block NSArray *expectedDailyForecasts = nil;

    beforeAll(^{
        expectedCurrentCondition = [[TCCurrentConditionViewModel alloc] initWithWeather:fakeWeatherService.fakeCurrentCondition];

        expectedHourlyForecasts = mapArray(fakeWeatherService.fakeHourlyForecasts, ^(TCWeather *weather) {
            return [[TCHourlyForecastViewModel alloc] initWithWeather:weather];
        });

        expectedDailyForecasts = mapArray(fakeWeatherService.fakeDailyForecasts, ^(TCWeather *weather) {
            return [[TCDailyForecastViewModel alloc] initWithWeather:weather];
        });
    });

    it(@"should fetch weather data and update view model's properties", ^{
        TCWeatherViewModel *viewModel = [[TCWeatherViewModel alloc]
                                         initWithLocationService:fakeLocationService
                                         weatherService:fakeWeatherService
                                         hourlyForecastLimit:3
                                         dailyForecastLimit:3];

        [viewModel.fetchWeatherCommand execute:nil];

        expect(viewModel.currentCondition).to.equal(expectedCurrentCondition);
        expect(viewModel.hourlyForecasts).to.equal(expectedHourlyForecasts);
        expect(viewModel.dailyForecasts).to.equal(expectedDailyForecasts);
    });
});

SpecEnd