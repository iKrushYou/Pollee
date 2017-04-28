//
//  CommentsTableViewController.h
//  Pollee
//
//  Created by Alex Krush on 4/24/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLPost.h"

@interface CommentsTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentBottomConstraint;

@property (strong, nonatomic) PLPost * post;
- (IBAction)commentAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

@end
