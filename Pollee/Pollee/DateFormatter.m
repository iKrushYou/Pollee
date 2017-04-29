//
//  DateFormatter.m
//  Pollee
//
//  Created by Alex Krush on 4/29/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "DateFormatter.h"

@implementation DateFormatter

+ (NSString *)dateStringForDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setDateFormat:@"MMM dd HH:mm"];
    
    return [dateFormatter stringFromDate:date];
}

@end
