//
//  TCFakeURLSession.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/7/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@class TCFakeURLSessionDataTask;

typedef void(^TCFakeURLSessionDataTaskCompletionHandler)(NSData *data, NSURLResponse *response, NSError *error);
typedef void(^TCFakeURLSessionDataTaskBlock)(NSURL *url, TCFakeURLSessionDataTaskCompletionHandler completionHandler);

@interface TCFakeURLSession : NSURLSession

/**
 * The fake @c NSURLSessionDataTask object that is returned from calling
 * @c dataTaskWithURL:completionHandler:.
 */
@property (nonatomic, strong, readonly) TCFakeURLSessionDataTask *fakeDataTask;

/**
 * Initializes the fake session object with a block object that will replace 
 * the @c dataTaskWithURL:completionHandler: method.
 */
- (instancetype)initWithDataTaskBlock:(TCFakeURLSessionDataTaskBlock)block;

@end
