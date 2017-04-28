//
//  ProfileCollectionViewController.h
//  Pollee
//
//  Created by Alex Krush on 4/19/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView.h>

@interface ProfileCollectionViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)viewFollowingAction:(id)sender;
- (IBAction)viewFollowersAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *postsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;

@property (strong, nonatomic) NSNumber * userId;
@property (weak, nonatomic) IBOutlet AsyncImageView *propicImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;

@end
