//
//  AppDelegate.h
//  startMe
//
//  Created by Matteo Gobbi on 19/12/12.
//  Copyright (c) 2012 Matteo Gobbi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, DataManagerDelegate> {
    BOOL pushRegistered;
    BOOL mutexNotif;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) FBSession *session;

@end
