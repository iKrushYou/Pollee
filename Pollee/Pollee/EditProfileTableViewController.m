//
//  EditProfileTableViewController.m
//  Pollee
//
//  Created by Alex Krush on 5/3/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "EditProfileTableViewController.h"
#import "APIClient.h"

@interface EditProfileTableViewController () {
    NSArray * settingsKeys;
    NSArray * settingsValues;
}

@end

@implementation EditProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    settingsKeys = @[
                     @"First Name",
                     @"Last Name",
                     @"Username",
                     @"Email",
                     @"Old Password",
                     @"New Password"
                     ];
    
    settingsValues = @[
                       [APIClient sharedInstance].user.firstName,
                       [APIClient sharedInstance].user.lastName,
                       [APIClient sharedInstance].user.username,
                       [APIClient sharedInstance].user.email,
                       @"",
                       @""
                       ];
    
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
    return settingsKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UITextField * textField = [cell viewWithTag:10];
    [textField setPlaceholder:[settingsKeys objectAtIndex:indexPath.row]];
    [textField setText:[settingsValues objectAtIndex:indexPath.row]];
    
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    if ([textField.placeholder containsString:@"password"]) {
        [textField setSecureTextEntry:YES];
    } else {
        [textField setSecureTextEntry:YES];
    }
    
    [textField setDelegate:self];
    
    [textField setTag:(100 + indexPath.row)];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
