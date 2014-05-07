//
//  TCFakeURLSessionDataTask.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/7/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@interface TCFakeURLSessionDataTask : NSURLSessionDataTask

@property (nonatomic, getter = isResumed, readonly) BOOL resumed;
@property (nonatomic, getter = isCancelled, readonly) BOOL cancelled;

- (void)resume;
- (void)cancel;

@end
