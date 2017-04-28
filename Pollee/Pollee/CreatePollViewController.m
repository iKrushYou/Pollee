//
//  CreatePollViewController.m
//  Pollee
//
//  Created by Alex Krush on 4/25/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "CreatePollViewController.h"
#import "APIClient.h"
#import "PLPost.h"
#import "PLPhoto.h"
#import <MBProgressHUD.h>

@interface CreatePollViewController () {
    long currentImage;
    NSMutableArray * images;
    NSMutableArray * photos;
    int imagesUploaded;
    MBProgressHUD * hud;
}

@end

@implementation CreatePollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    images = [[NSMutableArray alloc] init];
    photos = [[NSMutableArray alloc] init];
    
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

- (IBAction)imageButtonAction:(id)sender {
    currentImage = [((UIButton *) sender) tag];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    UIImageView * imageView = [self.view viewWithTag:(10 + currentImage)];
    imageView.image = chosenImage;
    [images addObject:chosenImage];
    UIButton * button = [self.view viewWithTag:currentImage];
    [button setImage:nil forState:UIControlStateNormal];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)createPost {
    NSDictionary * params = @{@"user_id" : [APIClient sharedInstance].user.id, @"title" : _pollTitleTextField.text};
    [[APIClient sharedInstance] POST:@"posts" parameters:params completion:^(OVCResponse *response, NSError *error) {
        PLPost * post = response.result;
        
        NSLog(@"post: %@", post);
        
        imagesUploaded = 0;
        for (NSString * url in photos) {
            [self createPhotoForPost:post withUrl:url];
        }
    }];
}

- (void)createPhotoForPost:(PLPost *)post withUrl:(NSString *)url {
    url = [NSString stringWithFormat:@"%@/%@", [APIClient sharedInstance].baseURL, url];
    
    NSDictionary * params = @{@"image_url" : url, @"post_id" : post.id, @"caption" : @""};
    
    [[APIClient sharedInstance] POST:@"photos" parameters:params completion:^(OVCResponse *response, NSError *error) {
        if (!error) {
            PLPhoto * photo = response.result;
            
            if (photo) {
                if (++imagesUploaded >= 4) {
                    [hud hideAnimated:YES];
                    
                    UITabBarController * tbc = self.tabBarController;
                    [tbc setSelectedIndex:0];
                }
            }
        } else {
            NSLog(@"error: %@", error);
        }
    }];
}

- (void)uploadImages {
    UIImageView * imageView1 = [self.view viewWithTag:11];
    UIImageView * imageView2 = [self.view viewWithTag:12];
    UIImageView * imageView3 = [self.view viewWithTag:13];
    UIImageView * imageView4 = [self.view viewWithTag:14];
    
    if (imageView1.image && imageView2.image && imageView3.image && imageView4.image) {
        [self uploadImage:imageView1.image];
        [self uploadImage:imageView2.image];
        [self uploadImage:imageView3.image];
        [self uploadImage:imageView4.image];
    }
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
        
        [photos addObject:url];
        
        if (photos.count >= 4) {
            [self createPost];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[UploadVC] error = %@", error);
    }];
}

- (IBAction)postAction:(id)sender {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    
    [self uploadImages];
}

@end
