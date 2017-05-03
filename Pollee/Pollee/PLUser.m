//
//  PLUser.m
//  Pollee
//
//  Created by Alex Krush on 4/25/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "PLUser.h"

@implementation PLUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id" : @"id",
             @"username": @"username",
             @"firstName": @"first_name",
             @"lastName" : @"last_name",
             @"email" : @"email",
             @"privacyPolicy" : @"privacy_policy",
             @"profilePictureUrl" : @"profile_picture_url",
             @"token" : @"token",
             @"createdOn": @"created_on",
             @"updatedOn": @"updated_on"
             };
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return dateFormatter;
}

+ (NSValueTransformer *)createdOnJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)updatedOnJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

@end
