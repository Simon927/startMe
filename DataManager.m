  //
//  DataManager.m
//  startMe
//
//  Created by Matteo Gobbi on 03/04/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "DataManager.h"
#import "NotificationViewController.h"
#import "UINavigationController+SGProgress.h"

@interface DataManager () {
    BOOL mutexNotification;
}

@end

@implementation DataManager

@synthesize delegate = _delegate;

static DataManager *instance = nil;

+(DataManager *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance = [[DataManager alloc] init];
        }
    }
    return instance;
}

-(id)init {
    self = [super init];
    if(self) {
        [self resetParam];
        mutexNotification = NO;
    }
    
    return self;
}

- (void)resetParam {
    _arrNotific = [[NSMutableArray alloc] initWithArray:[self getNotificationArray]];
}

- (NSMutableArray *)getNotificationArray {
    NSArray *arr = [Utility getNotifications];
    NSMutableArray *notifications = [NSMutableArray arrayWithCapacity:0];
    for(NSDictionary *n in arr) {
        Notification *notific = [[Notification alloc] initWithDictonary:n];
        [notifications addObject:notific];
    }
    return notifications;
}


- (void)updateBadgeNotification {
    if(!self.communityViewController) return;
    
    
    UINavigationController *navNotificViewController = [self.communityViewController.viewControllers objectAtIndex:INDEX_OF_NOTIFICATIONS];
    
    [navNotificViewController.tabBarItem setBadgeValue:[self getBadgeNotifications]];

}

-(NSString *)getBadgeNotifications {
    //Return badge number
    NSString *strLastRead = [Utility getDefaultValueForKey:NOTIFICATION_LAST_READ];
    if([strLastRead isEqualToString:@""]) strLastRead = @"0";
    
    NSArray *arr = [[Utility getNotifications] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"is_new LIKE '1' AND id > %@", strLastRead]];
    
    int new = [arr count];
    NSString *badgeValue = nil;
    
    if(new > 0) badgeValue = [NSString stringWithFormat:@"%d",new];
    
    return badgeValue;
}


- (void)logout {
    
    //Sen logout
    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
    NSString *session = [Utility encryptString:[Utility getSession]];
    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
    NSString *method = [Utility encryptString:SERVICE_LOGOUT];
    
    //Creo la stringa di inserimento
    NSString *str = [URL_SERVER stringByAppendingString:@"request.php"];
    
    //Start parser thread
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setPostValue:device forKey:@"device"];
    [request setPostValue:session forKey:@"session"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
    [request setPostValue:method forKey:@"method"];
    [request setDelegate:self];
    [request startAsynchronous];
    
    
    //Local//
    
    //Logout facebook
    if(FBSession.activeSession.isOpen)
        [FBSession.activeSession closeAndClearTokenInformation];

    //Clear user default
    [Utility setDefaultValue:@"" forKey:USER_ID];
    [Utility setDefaultValue:@"" forKey:USER_SESSION];
    [Utility setDefaultValue:@"" forKey:USER_FACEBOOK_LOGIN];
    [Utility setDefaultValue:@"" forKey:USER_IMG_PROFILE];
    [Utility setDefaultValue:@"" forKey:USER_NICKNAME];
}


- (void)getNotifications {
    if(mutexNotification) return;
    mutexNotification = YES;
    
    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
    NSString *session = [Utility encryptString:[Utility getSession]];
    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
    NSString *method = [Utility encryptString:SERVICE_GET_NOTIFICATIONS];
    
    //Attach last notifications received
    NSString *notif_last_refresh = [Utility getDefaultValueForKey:NOTIFICATION_LAST_REFRESH];
    notif_last_refresh = (![notif_last_refresh isEqualToString:@""]) ? [Utility encryptString:notif_last_refresh] : [Utility encryptString:@"0"];
    //***//
    
    //Attach last read notifications received
    NSString *last_read_notific = [Utility getDefaultValueForKey:NOTIFICATION_LAST_READ];
    last_read_notific = (last_read_notific) ? [Utility encryptString:last_read_notific] : [Utility encryptString:@"0"];
    //***//
    

    NSString *str = [URL_SERVER stringByAppendingString:@"request.php"];
    
    //Start parser thread
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setPostValue:device forKey:@"device"];
    [request setPostValue:session forKey:@"session"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
    [request setPostValue:method forKey:@"method"];
    [request setPostValue:notif_last_refresh forKey:@"notif_last_refresh"];
    [request setPostValue:last_read_notific forKey:@"id_last_read_notific"];
    [request setMethod:SERVICE_GET_NOTIFICATIONS];
    [request setDelegate:self];
    [request startAsynchronous];
}



//Login parser end
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request.method isEqualToString:SERVICE_GET_NOTIFICATIONS]) {
        if (request.responseStatusCode == 200) {
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [responseString JSONValue];
            
            NSString *logged = [responseDict valueForKey:@"logged"];
            
            if([logged isEqualToString:@"1"]) {
            
                
                //Controllo se ci sono nuove notifiche
                NSArray *new_notifications = (NSArray *)[responseDict valueForKey:@"new_notifications"];
                
                
                
                if([new_notifications count] > 0) {
                    
                    NSMutableArray *dictNotifications = [NSMutableArray arrayWithArray:[Utility getNotifications]];
                    
                    //Check how much notifications i have downloaded. If are more than the max that i can store, delete the old notifications.
                    if([new_notifications count] >= MAX_SAVED_NOTIFICATIONS) {
                        [dictNotifications removeAllObjects];
                        [_arrNotific removeAllObjects];
                    } else if([new_notifications count]+[dictNotifications count] >= MAX_SAVED_NOTIFICATIONS) {
                        int len = MAX_SAVED_NOTIFICATIONS-([new_notifications count]+[dictNotifications count]);
                        NSRange range = NSMakeRange(0, (len < 0) ? 0 : len);
                        [dictNotifications removeObjectsInRange:range];
                        [_arrNotific removeObjectsInRange:range];
                    }
                    
                    

                    for(int i=[new_notifications count]-1; i>=0; i--) {
                        Notification *notific = [[Notification alloc] initWithEncryptedDictonary:[new_notifications objectAtIndex:i]];
                        
                        //If exists
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id LIKE '%@'", notific.id_notific]];
                        NSArray *match = [dictNotifications filteredArrayUsingPredicate:predicate];
                        if([match count] > 0) {
                            if(!notific.is_new) {
                                
                                int notificationIndex = [dictNotifications indexOfObject:[match objectAtIndex:0]];
                                
                                //Check if the notification is valid or corresponding at a comment or post deleted
                                if(notific.type == kNotificationTypeFollowed || (![notific.title_post isEqualToString:@""] && ((notific.type != kNotificationTypeTaggedComment && notific.type != kNotificationTypeComment) || ![notific.descr_comment isEqualToString:@""])))
                                    [dictNotifications replaceObjectAtIndex:notificationIndex withObject:[notific toDictionary]];
                                else
                                    [dictNotifications removeObjectAtIndex:notificationIndex];
                            }
                        } else {
                            //Add it in the array of notifications
                            //Check if the notification is valid or corresponding at a comment or post deleted
                            if(notific.type == kNotificationTypeFollowed || (![notific.title_post isEqualToString:@""] && ((notific.type != kNotificationTypeTaggedComment && notific.type != kNotificationTypeComment) || ![notific.descr_comment isEqualToString:@""])))
                                [dictNotifications insertObject:[notific toDictionary] atIndex:0];
                        }
                        
                        [notific release];
                    }
                    
                    
                    //Save the array
                    [Utility setDefaultObject:dictNotifications forKey:NOTIFICATIONS_DOWNLOADED];

                    if(!self.communityViewController) return;
                    
                    
                    UINavigationController *navController = [[DataManager getInstance].communityViewController.viewControllers objectAtIndex:INDEX_OF_NOTIFICATIONS];
                    
                    if([self.communityViewController selectedIndex] != INDEX_OF_NOTIFICATIONS || [navController.viewControllers objectAtIndex:0] != navController.topViewController) {
                        //Update the badge if i'm not in notification controller
                        [self updateBadgeNotification];
                    }
                    /*
                    else {
                        //Set the delegate
                        if(_delegate) _delegate = (NotificationViewController *)[navNotificViewController.viewControllers objectAtIndex:0];
                    }
                    */
                    //Refresh array notifications actually initializated
                    [_arrNotific removeAllObjects];
                    [_arrNotific addObjectsFromArray:[self getNotificationArray]];
                    
                }
                //*****//
            }
            
            //Set last followed's refresh
            NSString *time = [responseDict valueForKey:@"notif_last_refresh"];
            if(time)
                [Utility setDefaultValue:time forKey:NOTIFICATION_LAST_REFRESH];
            
        }
        mutexNotification = NO;
        
        if(_delegate) {
            [_delegate requestFromDManDidFinish:request];
            [self setDelegate:nil];
        }
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if([request.method isEqualToString:SERVICE_GET_NOTIFICATIONS]) mutexNotification = NO;
    
    NSError *error = [request error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    if(_delegate)
        [_delegate requestFromDManFailed:request];

}


#pragma mark - post request methods

-(void)postWithTitle:(NSString *)title descr:(NSString *)descr imageData:(NSData *)imageData mediaLink:(NSString *)mediaLink {
    _isSendingPost = YES;
    
    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
    NSString *session = [Utility encryptString:[Utility getSession]];
    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
    NSString *method = [Utility encryptString:SERVICE_POST];
    
    //Creo la stringa di inserimento
    NSString *str = [URL_SERVER stringByAppendingString:@"post.php"];
    
    //Start parser thread
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setDidFinishSelector:@selector(postRequestFinished:)];
    [request setDidFailSelector:@selector(postRequestFailed:)];
    [request setPostValue:device forKey:@"device"];
    [request setPostValue:session forKey:@"session"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
    [request setPostValue:method forKey:@"method"];
    [request setPostValue:title forKey:@"title"];
    [request setPostValue:descr forKey:@"descr"];
    [request setPostValue:mediaLink forKey:@"media_link"];
    
    if(imageData)
        [request setData:imageData withFileName:@"image" andContentType:@"image/jpeg" forKey:@"photo"];
    
    [request setDelegate:self];
    
    [request setUploadProgressDelegate:self];
    [request setShowAccurateProgress:YES];
    [request startAsynchronous];
}


- (void)setProgress:(float)progress
{
    UINavigationController *navNotificViewController = [self.communityViewController.viewControllers objectAtIndex:INDEX_OF_EXPLORE];
    [navNotificViewController setSGProgressPercentage:progress*100.0];
}


//Login parser end
- (void)postRequestFinished:(ASIHTTPRequest *)request
{
    _isSendingPost = NO;
    BOOL success = NO;
    
    //Only if controller isn't presented with curl
    if (request.responseStatusCode == 200) {
        NSString *responseString = [request responseString];
        NSDictionary *responseDict = [responseString JSONValue];
        
        NSString *logged = [responseDict valueForKey:@"logged"];
        
        if([logged isEqualToString:@"1"]) {
            //Sessione valida, controllo se l'inserimento è andato a buon fine
            NSString *response = [responseDict valueForKey:@"response"];
            
            if([response isEqualToString:@"-1"]) {
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else if ([response isEqualToString:@"INVALIDtitle"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[NSString stringWithFormat:NSLocalizedString(@"INVALIDtitlePost", nil),POST_TITLE_MIN_LENGHT] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else if ([response isEqualToString:@"INVALIDdescr"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[NSString stringWithFormat:NSLocalizedString(@"INVALIDdescrPost", nil),POST_DESCR_MIN_LENGHT] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else if ([response isEqualToString:@"ERRORonlyTitle"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"ERRORonlyTitlePost", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else if ([response isEqualToString:@"INVALIDmedia"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"INVALIDmediaPost", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else if([response isEqualToString:@"1"]) {
                //Post success
                success = YES;
            }
            
        } else if([logged isEqualToString:@"OLDappVersion"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageVersionOld", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [[DataManager getInstance] logout];
            [_communityViewController dismissViewControllerAnimated:YES completion:nil];
        } else if([logged isEqualToString:@"-1"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else if([logged isEqualToString:@"0"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[NSString stringWithFormat:NSLocalizedString(@"messageLoginError", nil), APP_TITLE] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [[DataManager getInstance] logout];
            [_communityViewController dismissViewControllerAnimated:YES completion:nil];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:NSLocalizedString(@"messageConnectionError", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
    //Success or not
    UINavigationController *navNotificViewController = [self.communityViewController.viewControllers objectAtIndex:INDEX_OF_EXPLORE];
    [navNotificViewController finishSGProgress];
}

- (void)postRequestFailed:(ASIHTTPRequest *)request {
    _isSendingPost = NO;

    //Post failed
    UINavigationController *navNotificViewController = [self.communityViewController.viewControllers objectAtIndex:INDEX_OF_EXPLORE];
    [navNotificViewController finishSGProgress];
    
    NSError *error = [request error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


-(void)dealloc {
    [super dealloc];
    
    [instance release];
    [_communityViewController release];
}

@end