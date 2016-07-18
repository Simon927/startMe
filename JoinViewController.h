//
//  JoinViewController.h
//  startMe
//
//  Created by Matteo Gobbi on 20/12/12.
//  Copyright (c) 2012 Matteo Gobbi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomViewController.h"

#import "User.h"

@interface JoinViewController : CustomViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate, MBProgressHUDDelegate> {
    UIBarButtonItem *btJoin;
    
    IBOutlet UITableView *tb;
    IBOutlet UIScrollView *myScroll;
}

@property (nonatomic, retain) User *user;

@end
