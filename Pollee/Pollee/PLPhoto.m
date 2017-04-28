//
//  PLPhoto.m
//  Pollee
//
//  Created by Alex Krush on 4/24/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "PLPhoto.h"
#import "PLVote.h"

@implementation PLPhoto

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id" : @"id",
             @"post": @"post",
             @"imageUrl": @"image_url",
             @"caption": @"caption",
             @"votes" : @"votes",
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

+ (NSValueTransformer *)postJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:PLPost.class];
}

+ (NSValueTransformer *)votesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:PLVote.class];
}

@end
