//
//  CreatePollViewController.h
//  Pollee
//
//  Created by Alex Krush on 4/25/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreatePollViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)imageButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
- (IBAction)postAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *pollTitleTextField;

@end
