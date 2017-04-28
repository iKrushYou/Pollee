//
//  FeedTableViewController.h
//  Pollee
//
//  Created by Alex Krush on 3/28/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PollPhotoView.h"

@interface FeedTableViewController : UITableViewController <PollPhotoViewDelegate>
- (IBAction)shareAction:(id)sender;

@end
