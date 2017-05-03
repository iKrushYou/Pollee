//
//  PLUser.h
//  Pollee
//
//  Created by Alex Krush on 4/25/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface PLUser : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSNumber * privacyPolicy;
@property (nonatomic, strong) NSURL * profilePictureUrl;
@property (nonatomic, strong) NSString * token;
@property (nonatomic, strong) NSDate * createdOn;
@property (nonatomic, strong) NSDate * updatedOn;

@end
