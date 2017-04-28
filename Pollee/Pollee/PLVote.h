//
//  PLVote.h
//  Pollee
//
//  Created by Alex Krush on 4/27/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "PLUser.h"
#import "PLPhoto.h"

@interface PLVote : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) NSNumber * userId;
@property (nonatomic, strong) PLPhoto * photo;
@property (nonatomic, strong) NSDate * createdOn;
@property (nonatomic, strong) NSDate * updatedOn;

@end
