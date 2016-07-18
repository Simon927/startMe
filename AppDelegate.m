//
//  AppDelegate.m
//  startMe
//
//  Created by Matteo Gobbi on 19/12/12.
//  Copyright (c) 2012 Matteo Gobbi. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "NotificationViewController.h"
#import "Constants.h"

@implementation AppDelegate

@synthesize session = _session;

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    mutexNotif = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:APP_STATUS_BAR_STYLE];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSString *value = [DataManager getInstance].getBadgeNotifications;
    if (value)
        [UIApplication sharedApplication].applicationIconBadgeNumber = [value intValue];
    else
        [UIApplication sharedApplication].applicationIconBadgeNumber = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if([Utility userIsLogged]) {
        DataManager *dman = [DataManager getInstance];
        dman.delegate = self;
        [dman getNotifications];
        mutexNotif = YES;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
    
    if(!pushRegistered)
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

// FBSample logic
// If we have a valid session at the time of openURL call, we handle Facebook transitions
// by passing the url argument to handleOpenURL; see the "Just Login" sample application for
// a more detailed discussion of handleOpenURL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if(mutexNotif) {
        mutexNotif = NO;
    } else {
        if([Utility userIsLogged]) {
            DataManager *dman = [DataManager getInstance];
            dman.delegate = self;
            [dman getNotifications];
        }
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *str = [NSString stringWithFormat:@"%@",deviceToken];
    NSString *newString = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    newString = [newString stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    pushRegistered = ([newString length] > 0);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:newString forKey:DEVICE_PUSH_TOKEN];
    [defaults synchronize];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}


#pragma mark - DataManger Delegate

-(void)requestFromDManDidFinish:(ASIHTTPRequest *)request {
    mutexNotif = NO;
    if([DataManager getInstance].communityViewController.selectedIndex == INDEX_OF_NOTIFICATIONS) {
        UINavigationController *navController = [[DataManager getInstance].communityViewController.viewControllers objectAtIndex:INDEX_OF_NOTIFICATIONS];
        [[(NotificationViewController *)[navController.viewControllers objectAtIndex:0] tableView] reloadData];
    }
}

-(void)requestFromDManFailed:(ASIHTTPRequest *)request {
    mutexNotif = NO;
}

@end
