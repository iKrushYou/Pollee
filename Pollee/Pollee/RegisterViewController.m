//
//  RegisterViewController.m
//  Pollee
//
//  Created by Alex Krush on 4/29/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "RegisterViewController.h"
#import <MBProgressHUD.h>
#import "APIClient.h"
#import "LoginViewController.h"

@interface RegisterViewController () {
    MBProgressHUD * hud;
}

@end

@implementation RegisterViewController

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

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _firstNameTextField) {
        [_lastNameTextField becomeFirstResponder];
    } else if (textField == _lastNameTextField) {
        [_usernameTextField becomeFirstResponder];
    } else if (textField == _usernameTextField) {
        [_emailTextField becomeFirstResponder];
    } else if (textField == _emailTextField) {
        [_passwordTextField becomeFirstResponder];
    } else {
        [self registerAction:nil];
    }
    
    return YES;
}

- (IBAction)registerAction:(id)sender {
    [self dismissKeyboard];
    
    if ([_firstNameTextField.text isEqualToString:@""] ||
        [_lastNameTextField.text isEqualToString:@""] ||
        [_usernameTextField.text isEqualToString:@""] ||
        [_emailTextField.text isEqualToString:@""] ||
        [_passwordTextField.text isEqualToString:@""]) {
        
        return;
    }
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud showAnimated:YES];
    
    NSDictionary * parameters = @{
                                  @"first_name" : _firstNameTextField.text,
                                  @"last_name" : _lastNameTextField.text,
                                  @"username" : _usernameTextField.text,
                                  @"email" : _emailTextField.text,
                                  @"password" : _passwordTextField.text
                                  };
    
    [[APIClient sharedInstance] POST:@"register" parameters:parameters completion:^(OVCResponse *response, NSError *error) {
        PLUser * user = response.result;
        NSLog(@"response: %@", response);
        
        if (!error) {
            [hud hideAnimated:YES];
            [[APIClient sharedInstance] setUser:user];
            
            LoginViewController * vc = (LoginViewController *)[self presentingViewController];
            
            [self dismissViewControllerAnimated:YES completion:^{
                [vc.userTextField setText:_usernameTextField.text];
                [vc.passwordTextField setText:_passwordTextField.text];
                [vc loginAction:nil];
            }];
        } else {
            NSLog(@"error: %@", error);
            NSDictionary * error = response.result;
            hud.mode = MBProgressHUDModeText;
            [hud.label setText:[error objectForKey:@"error"]];
            [hud hideAnimated:YES afterDelay:1.5];
        }
    }];
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
