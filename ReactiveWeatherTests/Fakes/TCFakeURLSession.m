//
//  TCFakeURLSession.m
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/7/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

#import "TCFakeURLSession.h"
#import "TCFakeURLSessionDataTask.h"

@interface TCFakeURLSession ()

@property (nonatomic, copy) TCFakeURLSessionDataTaskBlock dataTaskBlock;

@end

@implementation TCFakeURLSession

- (instancetype)initWithDataTaskBlock:(TCFakeURLSessionDataTaskBlock)block;
{
    self = [super init];
    if (nil == self) { return nil; }

    _dataTaskBlock = [block copy];

    return self;
}

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    // `completionHandler` block must be provided.
    // Otherwise, it is a programmer error and we should fail fast!
    NSParameterAssert(completionHandler);

    // Calls the block that will replace this method's implementation.
    self.dataTaskBlock(url, completionHandler);

    NSURLSessionDataTask *fakeDataTask = [[TCFakeURLSessionDataTask alloc] init];
    return fakeDataTask;
}

@end
