//
//  Post.h
//  Pollee
//
//  Created by Alex Krush on 4/24/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "PLUser.h"

@interface PLPost : MTLModel <MTLJSONSerializing>

@property (readonly, nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) PLUser * user;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSArray * photos;
@property (nonatomic, strong) NSArray * comments;
@property (nonatomic, strong) NSDate * createdOn;
@property (nonatomic, strong) NSDate * updatedOn;

@end
