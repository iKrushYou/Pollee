//
//  PLComment.h
//  Pollee
//
//  Created by Alex Krush on 4/24/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "PLUser.h"
#import "PLPost.h"

@interface PLComment : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) PLUser * user;
@property (nonatomic, strong) PLPost * post;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSDate * createdOn;
@property (nonatomic, strong) NSDate * updatedOn;

@end
