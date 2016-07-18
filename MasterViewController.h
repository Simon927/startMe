//
//  MasterViewController.h
//  startMe
//
//  Created by Matteo Gobbi on 19/12/12.
//  Copyright (c) 2012 Matteo Gobbi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommunityViewController;

@interface MasterViewController : CustomViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate, MBProgressHUDDelegate> {
    UIBarButtonItem *btLogin;
    
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UIButton *btJoinFB;
    IBOutlet UIButton *btSignIn;
    IBOutlet UIButton *btResetPass;
    
    DataManager *dman;
}

@property (nonatomic, retain) IBOutlet UITableView *tb;

-(IBAction)resetPass:(id)sender;

-(IBAction)joinFB:(id)sender;
-(void)login;

@end
