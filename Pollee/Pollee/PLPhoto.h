//
//  PLPhoto.h
//  Pollee
//
//  Created by Alex Krush on 4/24/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "PLPost.h"

@interface PLPhoto : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber * id;
@property (nonatomic, strong) PLPost * post;
@property (nonatomic, strong) NSURL * imageUrl;
@property (nonatomic, strong) NSString * caption;
@property (nonatomic, strong) NSArray * votes;
@property (nonatomic, strong) NSDate * createdOn;
@property (nonatomic, strong) NSDate * updatedOn;

@end
