//
//  PollPhotoView.m
//  Pollee
//
//  Created by Alex Krush on 4/19/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "PollPhotoView.h"
#import "APIClient.h"
#import <MBProgressHUD.h>
#import "PLVote.h"

@implementation PollPhotoView {
    bool miniView;
    MBProgressHUD * hud;
}

@synthesize image1, image2, image3, image4;
@synthesize image1Label, image2Label, image3Label, image4Label;
@synthesize image1Likes, image2Likes, image3Likes, image4Likes;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)handleImageLike:(NSInteger)index {
    if (miniView) return;
    
    NSLog(@"handleImageLike");
    
    [self updateLabels];
    
    if (index - 1 < _post.photos.count) {
        PLPhoto * photo = (PLPhoto *)_post.photos[index - 1];
        
        [self votePhoto:photo];
    }
}

- (void)initStuff {
    [[NSBundle mainBundle] loadNibNamed:@"PollPhotoView" owner:self options:nil];
    NSLog(@"frame: [%f, %f]", self.frame.size.width, self.frame.size.height);
    [self.view setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:self.view];
    
    image1Likes = 0;
    image2Likes = 0;
    image3Likes = 0;
    image4Likes = 0;
    
    miniView = NO;
    
    [self updateLabels];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initStuff];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initStuff];
    }
    return self;
}

- (IBAction)doulbeTapAction:(id)sender {
    NSLog(@"double tap");
}
- (IBAction)image1Action:(id)sender {
    [self handleImageLike:1];
}
- (IBAction)image2Action:(id)sender {
    [self handleImageLike:2];
}
- (IBAction)image3Action:(id)sender {
    [self handleImageLike:3];
}
- (IBAction)image4Action:(id)sender {
    [self handleImageLike:4];
}

- (void)updateLabels {
    NSArray * labelArray = @[image1Label, image2Label, image3Label, image4Label];
    
    for (int i = 0; i < _post.photos.count; i++) {
        PLPhoto * photo = (PLPhoto *)_post.photos[i];
        UILabel * label = labelArray[i];
        [label setText:[NSString stringWithFormat:@"%lu", photo.votes.count]];
        
        bool voted = NO;
        for (PLVote * vote in photo.votes) {
            NSLog(@"checking vote %@", vote.userId);
            if ([vote.userId isEqual:[APIClient sharedInstance].user.id]) {
                NSLog(@"Voted");
                voted = YES;
            }
        }
        if (voted) {
            //rgb(46, 204, 113)
            [label setTextColor:[UIColor whiteColor]];
            [label.superview setBackgroundColor:[UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1.0]];
        } else {
            //
            [label setTextColor:[UIColor darkGrayColor]];
            [label.superview setBackgroundColor:[UIColor colorWithRed:236/255.0 green:240/255.0 blue:241/255.0 alpha:1.0]];
        }
    }
}

- (void)setMiniView {
    [image1Label.superview setHidden:YES];
    [image2Label.superview setHidden:YES];
    [image3Label.superview setHidden:YES];
    [image4Label.superview setHidden:YES];
    miniView = YES;
}

- (void)setPost:(PLPost *)post {
    _post = post;
    
    NSArray * imageArray = @[image1, image2, image3, image4];
    
    for (int i = 0; i < _post.photos.count; i++) {
        [imageArray[i] setImageURL:((PLPhoto *)_post.photos[i]).imageUrl];
    }
    
    [self updateLabels];
}

- (void)votePhoto:(PLPhoto *)photo {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud showAnimated:YES];
    
    NSDictionary * parameters = @{
                                  @"user_id" : [APIClient sharedInstance].user.id,
                                  @"photo_id" : photo.id
                                  };
    
    [[APIClient sharedInstance] PUT:@"vote" parameters:parameters completion:^(OVCResponse *response, NSError *error) {
        NSLog(@"voted: %@", response);
        if (!error) {
            [hud hideAnimated:YES];
            
            id<PollPhotoViewDelegate> strongDelegate = self.delegate;
            
            if ([strongDelegate respondsToSelector:@selector(pollPhotoView:didVoteOnPost:forPhoto:)]) {
                NSLog(@"delegate - index: %ld", (long)index);
                [strongDelegate pollPhotoView:self didVoteOnPost:_post forPhoto:photo];
            }
        } else {
            hud.mode = MBProgressHUDModeText;
            [hud.label setText:@"Error"];
            [hud hideAnimated:YES afterDelay:500];
        }
    }];
}

@end
