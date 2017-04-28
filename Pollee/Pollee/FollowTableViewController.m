//
//  FollowTableViewController.m
//  Pollee
//
//  Created by Alex Krush on 4/21/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "FollowTableViewController.h"
#import "APIClient.h"
#import "PLUser.h"
#import "ProfileCollectionViewController.h"
#import <MBProgressHUD.h>


@interface FollowTableViewController () {
    MBProgressHUD * hud;
}

@end

@implementation FollowTableViewController

//@synthesize users;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSArray *)getUsers {
    if (_followType == 0) {
        return _users;
    } else if (_followType == 1) {
        return _followers;
    } else {
        return _following;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getUsers].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell" forIndexPath:indexPath];
    
    PLUser * user = [[self getUsers] objectAtIndex:indexPath.row];
    
    UILabel * nameLabel = [cell viewWithTag:10];
    UILabel * userLabel = [cell viewWithTag:11];
    UIButton * followButton = [cell viewWithTag:20];
    AsyncImageView * image = [cell viewWithTag:30];
    
    [nameLabel setText:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
    [userLabel setText:user.username];
    [followButton setTitle:@"follow" forState:UIControlStateNormal];
    
    for (PLUser * otherUser in _userFollowing) {
        if ([user.id isEqual:otherUser.id]) {
            [followButton setTitle:@"unfollow" forState:UIControlStateNormal];
        }
    }
    
//    [followButton setTag:indexPath.row];
    
    [image setImageURL:user.profilePictureUrl];
    
    return cell;
}

- (void)followUser:(PLUser *)user {
    NSDictionary * parameters = @{
                                  @"follower_id" : [APIClient sharedInstance].user.id,
                                  @"followee_id" : user.id
                                  };
    
    [[APIClient sharedInstance] PUT:@"following" parameters:parameters completion:^(OVCResponse *response, NSError *error) {
        _userFollowing = response.result;
        
        NSLog(@"response: %@", response);
        NSLog(@"error: %@", error);
        
        [hud hideAnimated:YES];
        
        [self.tableView reloadData];
    }];
}

- (void)unfollowUser:(PLUser *)user {
    NSDictionary * parameters = @{
                                  @"follower_id" : [APIClient sharedInstance].user.id,
                                  @"followee_id" : user.id
                                  };
    
    [[APIClient sharedInstance] DELETE:@"following" parameters:parameters completion:^(OVCResponse *response, NSError *error) {
        _userFollowing = response.result;
        
        NSLog(@"response: %@", response);
        NSLog(@"error: %@", error);
        
        [hud hideAnimated:YES];
        
        [self.tableView reloadData];
    }];
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PLUser * user = [[self getUsers] objectAtIndex:indexPath.row];
    UITabBarController * tabBarVC = (UITabBarController *)[self presentingViewController];
    UINavigationController * nvc = (UINavigationController *)tabBarVC.viewControllers[2];

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProfileCollectionViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileView"];
    [vc setUserId:user.id];
    [nvc pushViewController:vc animated:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)followAction:(id)sender {
    [hud removeFromSuperview];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    
    UIButton * button = (UIButton *)sender;
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    if ([button.titleLabel.text isEqualToString:@"follow"]) {
        [self followUser:[[self getUsers] objectAtIndex:indexPath.row]];
    } else {
        [self unfollowUser:[[self getUsers] objectAtIndex:indexPath.row]];
    }
}
@end
