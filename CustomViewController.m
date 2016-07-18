//
//  CustomViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 05/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "CustomViewController.h"

@interface CustomViewController () {
    BOOL isLoading;
}

@end

@implementation CustomViewController

#pragma mark - public methods

//Active loading and disable interface
-(void)setModeLoading:(BOOL)active withText:(NSString *)text {
    isLoading = active;
    [self.view setUserInteractionEnabled:!active];
    
    if(active) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = text;
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}


-(void)startModeLoadingWithText:(NSString *)text {
    [self setModeLoading:YES withText:text];
}

-(void)stopModeLoading {
    [self setModeLoading:NO withText:@""];
}

-(BOOL)isLoading {
    return isLoading;
}


@end
