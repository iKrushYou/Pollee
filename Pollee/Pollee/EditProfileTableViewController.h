//
//  EditProfileTableViewController.h
//  Pollee
//
//  Created by Alex Krush on 5/3/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLUser.h"

@interface EditProfileTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) PLUser * user;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
