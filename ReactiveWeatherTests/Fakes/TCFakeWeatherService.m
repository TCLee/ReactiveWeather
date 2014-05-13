//
//  TCFakeWeatherService.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/13/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import <Mantle/Mantle.h>

#import "TCFakeWeatherService.h"
#import "TCWeather.h"
#import "TCDailyForecast.h"

@implementation TCFakeWeatherService

- (instancetype)init
{
    self = [super init];
    if (nil == self) { return nil; }

    NSDictionary *currentConditionJSONDictionary = [self JSONDictionaryFromFilename:@"CurrentCondition.json"];
    _fakeCurrentCondition = [self weatherFromJSONDictionary:currentConditionJSONDictionary];

    NSArray *hourlyForecastsJSONArray = [self JSONDictionaryFromFilename:@"HourlyForecasts.json"][@"list"];
    _fakeHourlyForecasts = @[
        [self weatherFromJSONDictionary:hourlyForecastsJSONArray[0]],
        [self weatherFromJSONDictionary:hourlyForecastsJSONArray[1]],
        [self weatherFromJSONDictionary:hourlyForecastsJSONArray[2]]
    ];

    NSArray *dailyForecastsJSONArray = [self JSONDictionaryFromFilename:@"DailyForecasts.json"][@"list"];
    _fakeDailyForecasts = @[
        [self dailyForecastFromJSONDictionary:dailyForecastsJSONArray[0]],
        [self dailyForecastFromJSONDictionary:dailyForecastsJSONArray[1]],
        [self dailyForecastFromJSONDictionary:dailyForecastsJSONArray[2]]
    ];

    return self;
}

#pragma mark TCWeatherService

- (RACSignal *)currentConditionForLocation:(__unused CLLocationCoordinate2D)coordinate
{
    return [RACSignal return:self.fakeCurrentCondition];
}

- (RACSignal *)hourlyForecastsForLocation:(__unused CLLocationCoordinate2D)coordinate limitTo:(__unused NSUInteger)count
{
    return [RACSignal return:self.fakeHourlyForecasts];
}

- (RACSignal *)dailyForecastsForLocation:(__unused CLLocationCoordinate2D)coordinate limitTo:(__unused NSUInteger)count
{
    return [RACSignal return:self.fakeDailyForecasts];
}

#pragma mark Private Methods

- (NSDictionary *)JSONDictionaryFromFilename:(NSString *)filename
{
    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:filename.stringByDeletingPathExtension withExtension:filename.pathExtension];
    NSAssert(nil != fileURL, @"Test file not found at URL: %@", fileURL);

    NSError *__autoreleasing readDataError = nil;
    NSData *data = [NSData dataWithContentsOfURL:fileURL options:kNilOptions error:&readDataError];
    NSAssert(nil != data, @"Fail to load test data. Error: %@", readDataError);

    NSError *__autoreleasing parseJSONError = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseJSONError];
    NSAssert(nil != object, @"Fail to parse JSON data. Error: %@", parseJSONError);

    return object;
}

- (id)modelOfClass:(Class)modelClass fromJSONDictionary:(NSDictionary *)dictionary
{
    NSError *__autoreleasing error = nil;
    id model = [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:dictionary error:&error];
    NSAssert(nil != model, @"Fail to map JSON dictionary to model class. Error: %@", error);

    return model;
}

- (TCWeather *)weatherFromJSONDictionary:(NSDictionary *)dictionary
{
    return [self modelOfClass:TCWeather.class fromJSONDictionary:dictionary];
}

- (TCDailyForecast *)dailyForecastFromJSONDictionary:(NSDictionary *)dictionary
{
    return [self modelOfClass:TCDailyForecast.class fromJSONDictionary:dictionary];
}

@end
