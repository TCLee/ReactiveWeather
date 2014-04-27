//
//  NSDateFormatter+TCForecastFormattingAdditions.h
//  ReactiveWeather
//
//  Created by Lee Tze Cheun on 4/27/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

@interface NSDateFormatter (TCForecastFormattingAdditions)

/**
 * Returns a shared @c NSDateFormatter instance that is 
 * cached for performance.
 *
 * As per Apple's Data Formatting Guide docs, date formatters should be
 * cache because it is expensive to create.
 */
+ (NSDateFormatter *)sharedDateFormatter;

/**
 * Returns a string representing the hour component of 
 * the date.
 *
 * @b Example:
 * @code
 * NSDate *now = NSDate.new;
 * NSString *result = [NSDateFormatter.sharedDateFormatter 
 *                     forecastHourStringFromDate:now];
 * NSLog(@"Time is now %@.", result);
 * // Prints out: Time is now 3:00 PM.
 * @endcode
 */
- (NSString *)forecastHourStringFromDate:(NSDate *)date;

/**
 * Returns a string representing the day component of
 * the date.
 *
 * @b Example:
 * @code
 * NSDate *now = NSDate.new;
 * NSString *result = [NSDateFormatter.sharedDateFormatter 
 *                     forecastDayStringFromDate:now];
 * NSLog(@"Today's day is %@.", result);
 * // Prints out: Today's day is Sunday.
 * @endcode
 */
- (NSString *)forecastDayStringFromDate:(NSDate *)date;

@end
