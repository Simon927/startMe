//
//  CustomTableView.m
//  startMe
//
//  Created by Matteo Gobbi on 14/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "CustomTableView.h"

@implementation CustomTableView


-(void)scrollToBottom {
    int numSec = [self numberOfSections]-1;
    if (numSec < 0) return;

    int numRows = [self numberOfRowsInSection:numSec] - 1;
    if (numRows < 0) return;
    
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:numRows inSection:numSec];
    [self scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


@end
