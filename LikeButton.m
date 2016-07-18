//
//  LikeButton.m
//  startMe
//
//  Created by Matteo Gobbi on 12/10/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "LikeButton.h"

@implementation LikeButton

- (void)awakeFromNib {
    [self setTitle:[@" " stringByAppendingString:NSLocalizedString(@"btLike", nil)] forState:UIControlStateNormal];
    [self setTitle:[@" " stringByAppendingString:NSLocalizedString(@"btNotLike", nil)] forState:UIControlStateSelected];
}

@end
