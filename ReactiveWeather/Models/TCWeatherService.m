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

@interface TCWeatherService ()

/**
 * The single URL session for all API requests.
 */
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation TCWeatherService

#pragma mark - Initialize

- (instancetype)init
{
    self = [super init];
    if (self) {
        _session = [NSURLSession sessionWithConfiguration:
                    [NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}

#pragma mark - OpenWeatherMap API URLs

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

#pragma mark - Weather Data Signals

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
    NSLog(@"Fetching JSON from URL: %@", serviceURL.absoluteString);

    return [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:serviceURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            [self handleDataTaskCompletionWithSubscriber:subscriber
                                            responseData:data
                                                response:response
                                                   error:error];
        }];
        [dataTask resume];

        // Cancel the network request when this signal is destroyed.
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
}

- (void)handleDataTaskCompletionWithSubscriber:(id<RACSubscriber>)subscriber
                                  responseData:(NSData *)data
                                      response:(NSURLResponse *)response
                                         error:(NSError *)error
{
    if (data) {
        NSError *__autoreleasing parseError = nil;
        id object = [NSJSONSerialization JSONObjectWithData:data
                                                    options:kNilOptions
                                                      error:&parseError];
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
    // Gets the JSON object from OpenWeatherMap API response and map it
    // to a TCWeatherCondition object.
    return [[self JSONObjectFromURL:[self currentWeatherURLWithCoordinate:coordinate]]
            tryMap:^(NSDictionary *JSONObject, NSError **errorPtr) {
                return [MTLJSONAdapter modelOfClass:[TCWeather class]
                                 fromJSONDictionary:JSONObject
                                              error:errorPtr];
            }];
}

- (RACSignal *)hourlyForecastsForLocation:(CLLocationCoordinate2D)coordinate
{
    return [self forecastWithURL:[self hourlyForecastURLWithCoordinate:coordinate]
                      modelClass:[TCWeather class]];
}

- (RACSignal *)dailyForecastsForLocation:(CLLocationCoordinate2D)coordinate
{
    return [self forecastWithURL:[self dailyForecastURLWithCoordinate:coordinate numberOfDays:7]
                      modelClass:[TCDailyForecast class]];
}

- (RACSignal *)forecastWithURL:(NSURL *)serviceURL
                    modelClass:(Class)modelClass
{
    // Summary: Maps the array of JSON object to an array of model classes.

    return [[[[self JSONObjectFromURL:serviceURL]
              // Get the "list" array from the JSON object that contains the
              // forecast data. Return the array as a RACSignal and flatten it.
              flattenMap:^(NSDictionary *JSONObject) {
                  return [JSONObject[@"list"] rac_sequence].signal;
              }]
              // Map each forecast JSON object into the equivalent
              // Objective-C model class.
              tryMap:^(NSDictionary *forecast, NSError **errorPtr) {
                  return [MTLJSONAdapter modelOfClass:modelClass
                                   fromJSONDictionary:forecast
                                                error:errorPtr];
              }]
              // Collect all the individual model objects into an array and
              // return it as the signal's value.
              collect];
}

@end
