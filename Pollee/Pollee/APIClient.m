//
//  APIClient.m
//  Pollee
//
//  Created by Alex Krush on 4/24/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "APIClient.h"
#import "PLPost.h"
#import "PLPhoto.h"
#import "PLComment.h"
#import "PLUser.h"

@implementation APIClient 

+ (NSString *)baseUrl {
    return @"http://bluelightsapp.com/pollee";
}

+ (NSDictionary *)modelClassesByResourcePath {
    return @{
             @"login": [PLUser class],
             @"register": [PLUser class],
             @"users": [PLUser class],
             @"users/#": [PLUser class],
             @"users/#/followers": [PLUser class],
             @"users/#/following": [PLUser class],
             @"users/#/profile-picture": [PLUser class],
             @"users/#/posts": [PLPost class],
             @"following": [PLUser class],
             @"posts": [PLPost class],
             @"photos/#": [PLPhoto class],
             @"posts/#/comments": [PLComment class]
             };
}

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:[self baseUrl]]];
    });
    
    return _sharedInstance;
}

- (void)setUserId:(NSNumber *)userId {
    _userId = userId;
    
    APIClient * apiClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:[APIClient baseUrl]]];
    
    NSString * uri = [NSString stringWithFormat:@"users/%@", userId];
    [apiClient GET:uri parameters:nil completion:^(OVCResponse *response, NSError *error) {
        _user = response.result;
    }];
}

@end
