//
//  APIClient.h
//  Pollee
//
//  Created by Alex Krush on 4/24/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <Overcoat/Overcoat.h>
#import "PLUser.h"

@interface APIClient : OVCHTTPSessionManager

+ (instancetype) sharedInstance;

+ (NSString *)baseUrl;

@property (strong, nonatomic) NSNumber * userId;
@property (strong, nonatomic) PLUser * user;

@end
