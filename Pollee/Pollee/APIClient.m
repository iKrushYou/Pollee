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
    return @"http://bluelightsapp.com/pollee/";
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

static APIClient * sharedInstance = nil;

+ (APIClient *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[APIClient alloc] initWithUser:nil];
    }
    return sharedInstance;
}

+ (void)resetSharedInstanceWithUser:(PLUser *)user {
    sharedInstance = [[APIClient alloc] initWithUser:user];
}

- (id)initWithUser:(PLUser *)user {
    self = [super initWithBaseURL:[NSURL URLWithString:[APIClient baseUrl]]];
    
    _user = user;
    [self.requestSerializer setValue:_user.token forHTTPHeaderField:@"Token"];
    
    return self;
}

- (void)setUser:(PLUser *)user {
    [APIClient resetSharedInstanceWithUser:user];
}

@end
