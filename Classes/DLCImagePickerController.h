//
//  DLCImagePickerController.h
//  DLCImagePickerController
//
//  Created by Dmitri Cherniak on 8/14/12.
//  Copyright (c) 2012 Dmitri Cherniak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"
#import "DLCBlurOverlayView.h"

@class DLCImagePickerController;

@protocol DLCImagePickerDelegate <NSObject>
@optional
- (void)imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(DLCImagePickerController *)picker;
@end

@interface DLCImagePickerController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate> 

@property (nonatomic, retain) IBOutlet GPUImageView *imageView;
@property (nonatomic, retain) id <DLCImagePickerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIButton *photoCaptureButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;

@property (nonatomic, retain) IBOutlet UIButton *cameraToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *blurToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *filtersToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *libraryToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *flashToggleButton;
@property (nonatomic, retain) IBOutlet UIButton *retakeButton;

@property (nonatomic, retain) IBOutlet UIScrollView *filterScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *filtersBackgroundImageView;
@property (nonatomic, retain) IBOutlet UIView *photoBar;
@property (nonatomic, retain) IBOutlet UIView *topBar;
@property (nonatomic, retain) DLCBlurOverlayView *blurOverlayView;
@property (nonatomic, retain) UIImageView *focusView;

@property (nonatomic, assign) CGFloat outputJPEGQuality;
@property (nonatomic, assign) CGSize requestedImageSize;

@end
