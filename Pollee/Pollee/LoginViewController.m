//
//  LoginViewController.m
//  Pollee
//
//  Created by Alex Krush on 4/24/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "LoginViewController.h"
#import "APIClient.h"
#import "PLUser.h"
#import <MBProgressHUD.h>

@interface LoginViewController () {
    MBProgressHUD * hud;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
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

- (IBAction)loginAction:(id)sender {
    [self dismissKeyboard];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud showAnimated:YES];
    
    NSDictionary * parameters = @{
                                  @"username" : _userTextField.text,
                                  @"password" : _passwordTextField.text
                                  };
    
    [[APIClient sharedInstance] POST:@"login" parameters:parameters completion:^(OVCResponse *response, NSError *error) {
        PLUser * user = response.result;
        
        if (!error) {
            NSLog(@"Response: %@", response);
            [hud hideAnimated:YES];
            [[APIClient sharedInstance] setUser:user];
            [self performSegueWithIdentifier:@"LoginSegue" sender:nil];
        } else {
            NSLog(@"Response: %@", response);
            NSLog(@"Error: %@", error);
            hud.mode = MBProgressHUDModeText;
            [hud.label setText:@"Error"];
            [hud hideAnimated:YES afterDelay:0.5];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _userTextField) {
        [_passwordTextField becomeFirstResponder];
    } else {
        [self loginAction:nil];
    }
    
    return YES;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

@end
