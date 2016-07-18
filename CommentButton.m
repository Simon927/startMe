//
//  CommentButton.m
//  startMe
//
//  Created by Matteo Gobbi on 12/10/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "CommentButton.h"

@implementation CommentButton

-(void)awakeFromNib {
    [self setTitle:[@" " stringByAppendingString:NSLocalizedString(@"btComment", nil)] forState:UIControlStateNormal];
}

@end
