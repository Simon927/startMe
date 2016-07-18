//
//  HomeViewController.h
//  startMe
//
//  Created by Matteo Gobbi on 31/12/12.
//  Copyright (c) 2012 Matteo Gobbi. All rights reserved.
//


#import "RefreshTableViewController.h"
#import "STTweetLabel.h"
#import "Post.h"
#import "User.h"
#import <MessageUI/MessageUI.h>

@interface ExploreViewController : RefreshTableViewController  <MFMailComposeViewControllerDelegate, UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet CustomTableView *tableList;

@property (retain, nonatomic) NSString *id_from;
@property (retain, nonatomic) NSString *nickname;

@property (retain, nonatomic) NSString *hashtag;

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *actLoad;

@property (retain, nonatomic) User *userInfo;

@end
