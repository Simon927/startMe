//
//  NotificationViewController.h
//  startMe
//
//  Created by Matteo Gobbi on 19/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshTableViewController.h"

@interface ListPersonViewController : RefreshTableViewController

@property (nonatomic, retain) NSMutableArray *arrUsers;

@property (assign) ListType listType;
@property (nonatomic, assign) NSString *user_id;
@property (nonatomic, assign) NSString *post_id;

@property (nonatomic, retain) NSString *nickname;

@end
