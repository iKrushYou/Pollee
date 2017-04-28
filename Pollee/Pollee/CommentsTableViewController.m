//
//  CommentsTableViewController.m
//  Pollee
//
//  Created by Alex Krush on 4/24/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "APIClient.h"
#import "PLComment.h"
#import "PLPost.h"
#import <AsyncImageView.h>
#import <MBProgressHUD.h>

@interface CommentsTableViewController () {
    NSArray * comments;
    MBProgressHUD * hud;
}

@end

@implementation CommentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    comments = [[NSArray alloc] init];
    
    self.tableView.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView.refreshControl addTarget:self
                            action:@selector(loadComments)
                  forControlEvents:UIControlEventValueChanged];
    
    [self loadComments];
}

- (void)loadComments {
    [hud removeFromSuperview];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    
    NSString * uri = [NSString stringWithFormat:@"posts/%@/comments", _post.id];
    [[APIClient sharedInstance] GET:uri parameters:nil completion:^(OVCResponse *response, NSError *error) {
        comments = response.result;
        
        [hud hideAnimated:YES];
        [self.tableView.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
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
    return comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    
    PLComment * comment = [comments objectAtIndex:indexPath.row];
    
    UILabel * nameLabel = [cell viewWithTag:10];
    UILabel * commentLabel = [cell viewWithTag:11];
    AsyncImageView * imageView = [cell viewWithTag:20];
    
    [nameLabel setText:[NSString stringWithFormat:@"%@", comment.user.username]];
    [commentLabel setText:comment.message];
    [imageView setImageURL:comment.user.profilePictureUrl];
        
    return cell;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [self.view endEditing:YES];
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.commentBottomConstraint.constant = keyboardSize.height;
        [self.view layoutIfNeeded];
    }];
    
}

- (void)keyboardDidHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 animations:^{
        self.commentBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)commentAction:(id)sender {
    NSString * commentString = _commentTextField.text;
    
    if (![commentString isEqualToString:@""]) {
        [self createComment:commentString];
    }
}

- (void)createComment:(NSString *)message {
    [hud removeFromSuperview];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    
    NSDictionary * parameters = @{
                                  @"user_id" : [APIClient sharedInstance].user.id,
                                  @"message" : message
                                  };
    
    NSString * uri = [NSString stringWithFormat:@"posts/%@/comments", _post.id];
    [[APIClient sharedInstance] POST:uri parameters:parameters completion:^(OVCResponse *response, NSError *error) {
        NSLog(@"response: %@", response);
        NSLog(@"error: %@", error);
        
        if (!error) {
            [_commentTextField setText:@""];
            
            [hud hideAnimated:YES];
            
            [self loadComments];
        } else {
            hud.mode = MBProgressHUDModeText;
            [hud.label setText:@"Error"];
            [hud hideAnimated:YES afterDelay:0.5];
        }
    }];
}
@end
