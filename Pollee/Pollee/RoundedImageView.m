//
//  RoundedImageView.m
//  Pollee
//
//  Created by Alex Krush on 4/21/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "RoundedImageView.h"

@implementation RoundedImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setClipsToBounds:YES];
        [self.layer setCornerRadius:self.frame.size.width/2];
    }
    
    return self;
}

@end
