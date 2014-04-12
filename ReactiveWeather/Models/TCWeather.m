//
//  TCWeather.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/11/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeather.h"

@implementation TCWeather

#pragma mark OpenWeatherMap Icon to Custom Icon Mapping

/**
 * Returns the static dictionary object that maps a weather 
 * condition icon code to an image file stored in our
 * app bundle.
 */
+ (NSDictionary *)imageMap
{
    static NSDictionary *_imageMap = nil;

    if (!_imageMap) {
        _imageMap = @{
            @"01d" : @"weather-clear",
            @"02d" : @"weather-few",
            @"03d" : @"weather-few",
            @"04d" : @"weather-broken",
            @"09d" : @"weather-shower",
            @"10d" : @"weather-rain",
            @"11d" : @"weather-tstorm",
            @"13d" : @"weather-snow",
            @"50d" : @"weather-mist",
            @"01n" : @"weather-moon",
            @"02n" : @"weather-few-night",
            @"03n" : @"weather-few-night",
            @"04n" : @"weather-broken",
            @"09n" : @"weather-shower",
            @"10n" : @"weather-rain-night",
            @"11n" : @"weather-tstorm",
            @"13n" : @"weather-snow",
            @"50n" : @"weather-mist",
        };
    }

    return _imageMap;
}

- (NSString *)imageName
{
    return TCWeather.imageMap[self.icon];
}

#pragma mark - JSON to Objective-C Properties Mapping

// Map the Objective-C properties to their respective JSON keys.
+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"};
}

#pragma mark - JSON Date to NSDate Transform

// Transforms a JSON's date property represented as UNIX time to/from
// an NSDate object.
+ (NSValueTransformer *)dateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSDate *(NSString *string) {
        return [NSDate dateWithTimeIntervalSince1970:string.doubleValue];
    } reverseBlock:^NSString *(NSDate *date) {
        return [NSString stringWithFormat:@"%.0f", date.timeIntervalSince1970];
    }];
}

+ (NSValueTransformer *)sunriseJSONTransformer
{
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer
{
    return [self dateJSONTransformer];
}

#pragma mark - JSON Array to NSString

+ (NSValueTransformer *)conditionDescriptionJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSString *(NSArray *array) {
        return array.firstObject;
    } reverseBlock:^NSArray *(NSString *string) {
        return @[string];
    }];
}

+ (NSValueTransformer *)conditionJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}

+ (NSValueTransformer *)iconJSONTransformer
{
    return [self conditionDescriptionJSONTransformer];
}

#pragma mark - Meters-Per-Second to Miles-Per-Hour Transform

#define MPS_TO_MPH 2.23694f

+ (NSValueTransformer *)windSpeedJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *windSpeedInMetersPerSecond) {
        return @(windSpeedInMetersPerSecond.floatValue * MPS_TO_MPH);
    } reverseBlock:^(NSNumber *windSpeedInMilesPerHour) {
        return @(windSpeedInMilesPerHour.floatValue / MPS_TO_MPH);
    }];
}

@end
