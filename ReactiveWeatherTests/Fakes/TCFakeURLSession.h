//
//  TCFakeURLSession.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/7/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

typedef void(^TCFakeURLSessionDataTaskCompletionHandler)(NSData *data, NSURLResponse *response, NSError *error);
typedef void(^TCFakeURLSessionDataTaskBlock)(NSURL *url, TCFakeURLSessionDataTaskCompletionHandler completionHandler);

@interface TCFakeURLSession : NSURLSession

- (instancetype)initWithDataTaskBlock:(TCFakeURLSessionDataTaskBlock)block;

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

@end
