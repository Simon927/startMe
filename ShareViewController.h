//
//  ShareViewController.h
//  startMe
//
//  Created by Matteo Gobbi on 05/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLCImagePickerController.h"

@interface ShareViewController : CustomViewController  <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate, MBProgressHUDDelegate, DLCImagePickerDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    IBOutlet UITableView *tb;
    IBOutlet UIBarButtonItem *btDone;
    IBOutlet UITableView *tbHashtag;
    IBOutlet UINavigationItem *navBar;
}

- (IBAction)post:(id)sender;
- (IBAction)cancel:(id)sender;

@end
