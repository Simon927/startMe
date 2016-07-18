//
//  CustomNavigationBar.m
//  startMe
//
//  Created by Matteo Gobbi on 14/10/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "CustomNavigationBar.h"

@implementation CustomNavigationBar

-(void)awakeFromNib {
    if([self respondsToSelector:@selector(setBarTintColor:)]) {
        [self setBarTintColor:NAVBAR_BACKGROUND_COLOR];
        [self setTintColor:NAVBAR_BUTTON_COLOR];
    } else {
        [self setTintColor:NAVBAR_BACKGROUND_COLOR];
    }
  

    [self
     setTitleTextAttributes:@{
                              UITextAttributeFont:NAVBAR_FONT,
                              UITextAttributeTextColor:NAVBAR_TITLE_COLOR,
                              }];
}

@end
