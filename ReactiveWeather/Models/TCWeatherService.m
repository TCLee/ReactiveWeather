//
//  TCWeatherService.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/11/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCWeatherService.h"
#import "TCWeather.h"
#import "TCDailyForecast.h"
#import "RACSignal+TCOperatorAdditions.h"
#import "CLLocation+TCDebugAdditions.h"

@interface TCWeatherService ()

@property (nonatomic, copy) NSURLSession *session;

@end

@implementation TCWeatherService

#pragma mark Initialize

- (instancetype)initWithSession:(NSURLSession *)aSession
{
    NSParameterAssert(nil != aSession);

    self = [super init];
    if (nil == self) { return nil; }

    _session = [aSession copy];

    return self;
}

#pragma mark OpenWeatherMap URLs

/**
 * URL string template to access OpenWeatherMap public API.
 */
static NSString * const TCOpenWeatherMapURLTemplate = @"http://api.openweathermap.org/data/2.5/%@?lat=%f&lon=%f&units=imperial";

/**
 * Returns the URL used to access OpenWeatherMap current weather data API.
 *
 * @param coordinate The coordinate of a location.
 */
- (NSURL *)currentWeatherURLWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSString *URLString = [NSString stringWithFormat:TCOpenWeatherMapURLTemplate,
                           @"weather", coordinate.latitude, coordinate.longitude];
    return [NSURL URLWithString:URLString];
}

/**
 * Returns the URL used to access OpenWeatherMap hourly forecast data API.
 *
 * @param coordinate The coordinate of a location.
 */
- (NSURL *)hourlyForecastURLWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSString *URLString = [NSString stringWithFormat:TCOpenWeatherMapURLTemplate,
                           @"forecast", coordinate.latitude, coordinate.longitude];
    return [NSURL URLWithString:URLString];
}

/**
 * Returns the URL used to access OpenWeatherMap daily forecast data API.
 *
 * @param coordinate The coordinate of a location.
 * @param numberOfDays The number of days of weather forecast data.
 */
- (NSURL *)dailyForecastURLWithCoordinate:(CLLocationCoordinate2D)coordinate
                             numberOfDays:(NSUInteger)numberOfDays
{
    NSMutableString *mutableURLString = [NSMutableString stringWithFormat:TCOpenWeatherMapURLTemplate,
                                         @"forecast/daily", coordinate.latitude, coordinate.longitude];
    [mutableURLString appendFormat:@"&cnt=%lu", (unsigned long)numberOfDays];

    return [NSURL URLWithString:mutableURLString];

}

#pragma mark Fetch Weather Data

/**
 * Fetches a JSON object from the given URL.
 *
 * @param aURL A valid URL to fetch the JSON object from.
 *
 * @return A signal that will send the JSON object then complete. 
 *         On network error or parsing error, it will send an error event.
 */
- (RACSignal *)JSONObjectFromURL:(NSURL *)serviceURL
{
    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        @weakify(self);
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:serviceURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            @strongify(self);
            [self handleDataTaskCompletionWithSubscriber:subscriber responseData:data response:response error:error];
        }];
        [dataTask resume];

        // Cancel the network request when this signal is destroyed.
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] setNameWithFormat:@"JSONObjectFromURL: %@", serviceURL];
}

- (void)handleDataTaskCompletionWithSubscriber:(id<RACSubscriber>)subscriber responseData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error
{
    if (data) {
        NSError *__autoreleasing parseError = nil;
        id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseError];
        
        if (object) {
            // Success - Send the parsed JSON object and then
            // the signal completes.
            [subscriber sendNext:object];
            [subscriber sendCompleted];
        } else {
            // Error - Failed to parse JSON response.
            [subscriber sendError:parseError];
        }
    } else {
        // Error - Failed to get valid response data.
        [subscriber sendError:error];
    }
}

- (RACSignal *)currentConditionForLocation:(CLLocationCoordinate2D)coordinate
{
    // Gets the JSON response from OpenWeatherMap API response and map it
    // to a `TCWeatherCondition` object.
    return [[[self JSONObjectFromURL:[self currentWeatherURLWithCoordinate:coordinate]]
        tryMap:^(NSDictionary *JSONObject, NSError **errorPtr) {
            return [MTLJSONAdapter modelOfClass:TCWeather.class
                             fromJSONDictionary:JSONObject
                                          error:errorPtr];
        }]
        setNameWithFormat:@"%@ -currentConditionForLocation: <%@>", self, tc_NSStringFromCoordinate(coordinate)];
}

- (RACSignal *)hourlyForecastsForLocation:(CLLocationCoordinate2D)coordinate
                                  limitTo:(NSUInteger)count
{
    return [[self forecastWithURL:[self hourlyForecastURLWithCoordinate:coordinate]
                      modelClass:TCWeather.class
                            limit:count]
            setNameWithFormat:@"%@ -hourlyForecastsForLocation: <%@> limitTo: %lu", self, tc_NSStringFromCoordinate(coordinate), (unsigned long)count];

}

- (RACSignal *)dailyForecastsForLocation:(CLLocationCoordinate2D)coordinate
                                 limitTo:(NSUInteger)count
{
    return [[self forecastWithURL:[self dailyForecastURLWithCoordinate:coordinate numberOfDays:count]
                      modelClass:TCDailyForecast.class
                            limit:count]
            setNameWithFormat:@"%@ -dailyForecastsForLocation: <%@> limitTo: %lu", self, tc_NSStringFromCoordinate(coordinate), (unsigned long)count];
}

- (RACSignal *)forecastWithURL:(NSURL *)serviceURL
                    modelClass:(Class)modelClass
                         limit:(NSUInteger)count
{
    return [[[[self JSONObjectFromURL:serviceURL]
        flattenMap:^(NSDictionary *JSONResponse) {
            NSArray *forecastList = JSONResponse[@"list"];

            // Maps each JSON item in the array into its equivalent
            // model class.
            return [[forecastList.rac_sequence.signal
                take:count]
                tryMap:^(NSDictionary *forecastItem, NSError **errorPtr) {
                    return [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:forecastItem error:errorPtr];
                }];
        }]
        // Collect the mapped model objects into a single array.
        collect]
        setNameWithFormat:@"forecastWithURL: %@ modelClass: %@ limit: %lu", serviceURL, NSStringFromClass(modelClass), (unsigned long)count];
}

@end
