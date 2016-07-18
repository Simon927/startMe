//
//  DataManager.h
//  startMe
//
//  Created by Matteo Gobbi on 03/04/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommunityViewController.h"

@class NotificationViewController, ASIHTTPRequest;

@protocol DataManagerDelegate
    - (void)requestFromDManDidFinish:(ASIHTTPRequest *)request;
    - (void)requestFromDManFailed:(ASIHTTPRequest *)request;
@end

@interface DataManager : NSObject {
    id<DataManagerDelegate> delegate;
}

@property (nonatomic, assign) id<DataManagerDelegate> delegate;

@property (nonatomic, retain) CommunityViewController *communityViewController;

@property (nonatomic, retain) NSMutableArray *arrNotific;

@property BOOL isSendingPost;

+(DataManager *)getInstance;

- (void)logout;
- (void)getNotifications;
- (void)resetParam;
- (void)updateBadgeNotification;
-(NSString *)getBadgeNotifications;

-(void)postWithTitle:(NSString *)title descr:(NSString *)descr imageData:(NSData *)imageData mediaLink:(NSString *)mediaLink;

@end
