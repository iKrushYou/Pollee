//
//  PollPhotoView.h
//  Pollee
//
//  Created by Alex Krush on 4/19/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView.h>
#import "PLPost.h"
#import "PLPhoto.h"

@protocol PollPhotoViewDelegate;

@interface PollPhotoView : UIView

@property (nonatomic, weak) id<PollPhotoViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *view;

@property (weak, nonatomic) IBOutlet AsyncImageView *image1;
- (IBAction)image1Action:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *image1Label;
@property (weak, nonatomic) IBOutlet AsyncImageView *image2;
- (IBAction)image2Action:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *image2Label;
@property (weak, nonatomic) IBOutlet AsyncImageView *image3;
- (IBAction)image3Action:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *image3Label;
@property (weak, nonatomic) IBOutlet AsyncImageView *image4;
- (IBAction)image4Action:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *image4Label;

@property int image1Likes, image2Likes, image3Likes, image4Likes;

@property (strong, nonatomic) PLPost * post;

- (void)setMiniView;

@end

@protocol PollPhotoViewDelegate <NSObject>

- (void)pollPhotoView:(PollPhotoView *)pollPhotoView didVoteOnPost:(PLPost *)post forPhoto:(PLPhoto *)photo;

@end
