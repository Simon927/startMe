//
//  CustomButton.m
//  startMe
//
//  Created by Matteo Gobbi on 02/09/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

-(void)awakeFromNib {
    UIImage *buttonImage = [[self backgroundImageForState:UIControlStateNormal]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [self setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    UIImage *buttonImageHighlight = [[self backgroundImageForState:UIControlStateHighlighted]
                                          resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [self setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    UIImage *buttonImageSelected = [[self backgroundImageForState:UIControlStateSelected]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [self setBackgroundImage:buttonImageSelected forState:UIControlStateSelected];
}


@end
