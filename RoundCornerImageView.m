//
//  RoundCornerImage.m
//  startMe
//
//  Created by Matteo Gobbi on 24/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "RoundCornerImageView.h"

@implementation RoundCornerImageView

-(void)awakeFromNib {
    [super awakeFromNib];
    CALayer * l = [self layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    
    // You can even add a border
    [l setBorderWidth:self.frame.size.width/IMG_PROFILE_BORDER_SCALE];
    [l setBorderColor:[[UIColor grayColor] CGColor]];
}

-(void)setBorderWidth:(float)width {
    [[self layer] setBorderWidth:width];
}

-(void)setCornerRadius:(float)radius {
    [[self layer] setCornerRadius:radius];
}

-(void)setBorderColor:(UIColor *)color {
    [[self layer] setBorderColor:[color CGColor]];
}


-(void)setCircleMask {
    [[self layer] setCornerRadius:self.frame.size.width/2.0];
}

@end
