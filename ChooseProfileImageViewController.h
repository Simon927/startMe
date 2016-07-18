//
//  ChooseProfileImageViewController.h
//  startMe
//
//  Created by Matteo Gobbi on 31/12/12.
//  Copyright (c) 2012 Matteo Gobbi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExploreViewController.h"

@interface ChooseProfileImageViewController : CustomViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate> {
    NSData *img_data;
    NSString *nickname;
  
    IBOutlet UIBarButtonItem *btDone;
    IBOutlet UIBarButtonItem *btCancel;
    IBOutlet UIButton *btTakePhoto;
    IBOutlet UIButton *btChoosePhoto;
    IBOutlet UIButton *btPhotoDefault;
    IBOutlet UIButton *btPhotoFacebook;
    IBOutlet UINavigationItem *navBar;
}


@property (retain, nonatomic) IBOutlet RoundCornerImageView *imgProfile;
@property (retain, nonatomic) IBOutlet UITextField *txtNickname;
@property (assign, nonatomic) ExploreViewController *delegate;
@property BOOL modalityNick;

- (IBAction)clickDone:(id)sender;
- (IBAction)takePhotoClick:(id)sender;
- (IBAction)clickCancel:(id)sender;

@end
