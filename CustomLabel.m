//
//  CustomLabel.m
//  startMe
//
//  Created by Matteo Gobbi on 23/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "CustomLabel.h"

@implementation CustomLabel

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setFont:[UIFont fontWithName:APP_FONT size:self.font.pointSize]];
}

@end
