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
 * The block that will replace the default implementation of 
 * @c dataTaskWithURL:completionHandler:.
 *
 * This block must not be @c nil, otherwise assertion will fail when calling 
 * @c dataTaskWithURL:completionHandler:.
 */
@property (nonatomic, copy) TCFakeURLSessionDataTaskBlock fakeDataTaskBlock;

@end
