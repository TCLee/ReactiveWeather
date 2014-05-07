//
//  TCFakeURLSessionDataTask.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 5/7/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@interface TCFakeURLSessionDataTask : NSURLSessionDataTask

/**
 * Returns @c YES when @c -cancel is called; @c NO otherwise.
 */
@property (nonatomic, getter = isCancelled, readonly) BOOL cancelled;

@end
