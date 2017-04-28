//
//  FeedTableViewController.m
//  Pollee
//
//  Created by Alex Krush on 3/28/17.
//  Copyright © 2017 Alex Krush. All rights reserved.
//

#import "FeedTableViewController.h"
#import "PollPhotoView.h"
#import "APIClient.h"
#import "PLPost.h"
#import "PLPhoto.h"
#import <AsyncImageView.h>
#import "CommentsTableViewController.h"

@interface FeedTableViewController () {
    NSArray * posts;
}

@end

@implementation FeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    posts = [[NSArray alloc] init];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(loadPosts)
                  forControlEvents:UIControlEventValueChanged];
    
    [self loadPosts];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadPosts];
}

- (void)loadPosts {
    
    [[APIClient sharedInstance] GET:@"posts" parameters:nil completion:^(OVCResponse *response, NSError *error) {
        posts = response.result;
        NSLog(@"response: %@", response);
        NSLog(@"error: %@", error);
        NSLog(@"posts: %@", posts);
        
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return posts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PollCell" forIndexPath:indexPath];
    
    PLPost * post = [posts objectAtIndex:indexPath.section];
    NSLog(@"Post: %@", post);
    
    AsyncImageView * propic = [cell viewWithTag:10];
    [propic setImageURL:post.user.profilePictureUrl];
    
    UILabel * titleLabel = [cell viewWithTag:11];
    [titleLabel setText:post.title];
    UILabel * dateLabel = [cell viewWithTag:12];
//    [dateLabel setText:post.createdOn];
    
    UIView * view = [cell viewWithTag:20];
    [view setBackgroundColor:[UIColor blueColor]];
    PollPhotoView * pollPhotoView = [[PollPhotoView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.width)];
    [pollPhotoView setPost:post];
    
    UIButton * commentButton = [cell viewWithTag:50];
    [commentButton setTag:(1000 + post.id.intValue)];
    
    UILabel * heartLabel = [cell viewWithTag:41];
    int heartCount = 0;
    for (PLPhoto * photo in post.photos) {
        heartCount += photo.votes.count;
    }
    [heartLabel setText:[NSString stringWithFormat:@"%d", heartCount]];
    
    UILabel * commentLabel = [cell viewWithTag:42];
    [commentLabel setText:[NSString stringWithFormat:@"%lu",post.comments.count]];
    NSLog(@"setting comment label: %lu", (unsigned long)post.comments.count);
    
    [[view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    pollPhotoView.delegate = self;
    [view addSubview:pollPhotoView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.frame.size.width + 64 + 48;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"commentSegue"]) {
        CommentsTableViewController * vc = [segue destinationViewController];
//        UIButton * button = (UIButton *)sender;
//        PLPost * post = [posts objectAtIndex:(button.tag - 1000)];
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        PLPost * post = [posts objectAtIndex:indexPath.section];
        
        [vc setPost:post];
    }
}

- (void)pollPhotoView:(PollPhotoView *)pollPhotoView didVoteOnPost:(PLPost *)post forPhoto:(PLPhoto *)photo {
    NSLog(@"User liked photo %@ on post %@", photo.id, post.id);
    
    [self loadPosts];
}

- (void)share {
    NSString *string = @"Share this post";
    NSURL *URL = [NSURL URLWithString:@"https://google.com"];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string, URL, UIActivityTypeCopyToPasteboard, UIActivityTypeMessage]
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                         // ...
                                     }];
}

- (IBAction)shareAction:(id)sender {
    [self share];
}
@end
