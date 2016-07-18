//
//  NotificationViewController.h
//  startMe
//
//  Created by Matteo Gobbi on 19/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshTableViewController.h"

@interface NotificationViewController : RefreshTableViewController <DataManagerDelegate>

@property (nonatomic, retain) NSMutableArray *arrNotific;


@end
