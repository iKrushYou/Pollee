//
//  FollowTableViewController.h
//  Pollee
//
//  Created by Alex Krush on 4/21/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView.h>
#import "PLUser.h"

@interface FollowTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)closeAction:(id)sender;

@property int followType;
@property (strong, nonatomic) PLUser * user;

@property (strong, nonatomic) NSArray * users;
@property (strong, nonatomic) NSArray * followers;
@property (strong, nonatomic) NSArray * following;
@property (strong, nonatomic) NSArray * userFollowing;

- (IBAction)followAction:(id)sender;

@end
