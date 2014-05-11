//
//  TCFakeURLSession.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/7/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCFakeURLSession.h"
#import "TCFakeURLSessionDataTask.h"

@implementation TCFakeURLSession

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSParameterAssert(nil != self.fakeDataTaskBlock);
    NSParameterAssert(nil != completionHandler);

    // Calls the block that will replace this method's implementation.
    self.fakeDataTaskBlock(url, completionHandler);

    // Create and return an empty fake data task object.
    _fakeDataTask = [[TCFakeURLSessionDataTask alloc] init];
    return self.fakeDataTask;
}

@end
