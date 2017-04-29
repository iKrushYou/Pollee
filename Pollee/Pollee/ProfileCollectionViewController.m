//
//  ProfileCollectionViewController.m
//  Pollee
//
//  Created by Alex Krush on 4/19/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "ProfileCollectionViewController.h"
#import "PollPhotoView.h"
#import "APIClient.h"
#import "PLUser.h"
#import "PLPost.h"
#import "FollowTableViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ProfileCollectionViewController () {
    NSArray * posts;
    PLUser * user;
    NSArray * users;
    NSArray * usersFollowing;
    NSArray * usersFollowers;
    NSArray * userFollowing;
    
    int loadCount;
    
    MBProgressHUD * hud;
}

@end

@implementation ProfileCollectionViewController

static NSString * const reuseIdentifier = @"PhotoCell";

static CGFloat cellMargin;
static CGFloat cellWidth;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cellMargin = 4;
    cellWidth = (self.view.frame.size.width - cellMargin * 5) / 3;
    
    if (!_userId) _userId = [APIClient sharedInstance].user.id;
    
    [self loadUser];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadUser];
}

- (void)loadUser {
    [hud removeFromSuperview];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    
    [hud showAnimated:YES];
    
    NSString * uri = [NSString stringWithFormat:@"users/%@", _userId];
    [[APIClient sharedInstance] GET:uri parameters:nil completion:^(OVCResponse *response, NSError *error) {
        user = response.result;
        
        [self updateProfile];
        
        loadCount = 0;
        
        [self loadPosts];
        [self getFollowing];
        [self getFollowers];
        [self getAllUsers];
        [self getUserFollowing];
    }];
}

- (void)checkFinishLoading {
    if (++loadCount >= 5) {
        [hud hideAnimated:YES];
    }
}

- (void)loadPosts {
    NSString * uri = [NSString stringWithFormat:@"users/%@/posts", _userId];
    [[APIClient sharedInstance] GET:uri parameters:nil completion:^(OVCResponse *response, NSError *error) {
        posts = response.result;
        NSLog(@"response: %@", response);
        NSLog(@"error: %@", error);
        NSLog(@"posts: %@", posts);
        
        [self.collectionView reloadData];
        [self updateProfile];
        
        [self checkFinishLoading];
    }];
}

- (void)getFollowing {
    NSString * uri = [NSString stringWithFormat:@"users/%@/following", _userId];
    [[APIClient sharedInstance] GET:uri parameters:nil completion:^(OVCResponse *response, NSError *error) {
        usersFollowing = response.result;
        
        [self updateProfile];
        [self checkFinishLoading];
    }];
}

- (void)getFollowers {
    NSString * uri = [NSString stringWithFormat:@"users/%@/followers", _userId];
    [[APIClient sharedInstance] GET:uri parameters:nil completion:^(OVCResponse *response, NSError *error) {
        usersFollowers = response.result;
        
        [self updateProfile];
        [self checkFinishLoading];
    }];
}

- (void)getAllUsers {
    NSString * uri = [NSString stringWithFormat:@"users"];
    [[APIClient sharedInstance] GET:uri parameters:nil completion:^(OVCResponse *response, NSError *error) {
        users = response.result;
        [self checkFinishLoading];
    }];
}

- (void)getUserFollowing {
    NSString * uri = [NSString stringWithFormat:@"users/%@/following", [APIClient sharedInstance].user.id];
    [[APIClient sharedInstance] GET:uri parameters:nil completion:^(OVCResponse *response, NSError *error) {
        userFollowing = response.result;
        [self checkFinishLoading];
    }];
}

- (void)updateProfile {
    if ([[APIClient sharedInstance].user.id isEqual:user.id]) {
        [_editProfileButton setHidden:NO];
        [_changeProPicButton setHidden:NO];
    } else {
        [_editProfileButton setHidden:YES];
        [_changeProPicButton setHidden:YES];
    }
    
    [_postsCountLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)posts.count]];
    [_followersCountLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)usersFollowers.count]];
    [_followingCountLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)usersFollowing.count]];
    
    [_nameLabel setText:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
    [_propicImageView setImageURL:user.profilePictureUrl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return posts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    PLPost * post = [posts objectAtIndex:indexPath.row];
    
    [cell setBackgroundColor:[UIColor redColor]];
    
    UIView * view = [cell viewWithTag:20];
    [view setBackgroundColor:[UIColor blueColor]];
    PollPhotoView * pollPhotoView = [[PollPhotoView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellWidth)];
    [pollPhotoView setMiniView];
    [pollPhotoView setPost:post];
    [[view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [view addSubview:pollPhotoView];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(cellWidth, cellWidth);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAllUsers"]) {
        FollowTableViewController * vc = [segue destinationViewController];
        [vc setFollowType:0];
        [vc setUser:user];
        [vc setUsers:users];
        [vc setFollowers:usersFollowers];
        [vc setFollowing:usersFollowing];
        [vc setUserFollowing:userFollowing];
    }
    
    if ([segue.identifier isEqualToString:@"showFollowers"]) {
        FollowTableViewController * vc = [segue destinationViewController];
        [vc setFollowType:1];
        [vc setUser:user];
        [vc setUsers:users];
        [vc setFollowers:usersFollowers];
        [vc setFollowing:usersFollowing];
        [vc setUserFollowing:userFollowing];
    }
    
    if ([segue.identifier isEqualToString:@"showFollowing"]) {
        FollowTableViewController * vc = [segue destinationViewController];
        [vc setFollowType:2];
        [vc setUser:user];
        [vc setUsers:users];
        [vc setFollowers:usersFollowers];
        [vc setFollowing:usersFollowing];
        [vc setUserFollowing:userFollowing];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self uploadImage:chosenImage];
}

- (void)uploadImage:(UIImage *)image {
    NSData * imageData = UIImageJPEGRepresentation(image, 0.5);
    
    NSString *path = [NSString stringWithFormat:@"%@/upload", [APIClient sharedInstance].baseURL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"newfile" fileName:@"newfile.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"[UploadVC] success = %@", responseObject);
        NSString * url = [((NSDictionary *) responseObject) objectForKey:@"url"];
        
        [self setProfilePicture:url];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[UploadVC] error = %@", error);
    }];
}

- (void)setProfilePicture:(NSString *)profilePictureUrl {
    NSDictionary * parameters = @{
                                  @"profile_picture_url" : profilePictureUrl
                                  };
    
    NSString * uri = [NSString stringWithFormat:@"users/%@/profile-picture", [APIClient sharedInstance].user.id];
    [[APIClient sharedInstance] PUT:uri parameters:parameters completion:^(OVCResponse *response, NSError *error) {
        user = response.result;
        
        NSLog(@"response: %@", response);
        NSLog(@"error: %@", error);
        
        [hud hideAnimated:YES];
        
        [self updateProfile];
    }];
}

- (IBAction)changeProPicAction:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
@end
