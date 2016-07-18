//
//  RefreshTableViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 03/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "RefreshTableViewController.h"

@interface RefreshTableViewController ()

@end

@implementation RefreshTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)refresh {
}

@end
