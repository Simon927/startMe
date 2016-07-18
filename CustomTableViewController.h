//
//  CustomViewController.h
//  startMe
//
//  Created by Matteo Gobbi on 05/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewController : UITableViewController <UIScrollViewDelegate>

-(void)setModeLoading:(BOOL)active withText:(NSString *)text;
-(void)startModeLoadingWithText:(NSString *)text;
-(void)stopModeLoading;
-(BOOL)isLoading;

@end
