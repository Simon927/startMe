//
//  SettingsViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 16/10/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//


#import "SettingsViewController.h"
#import "MatchingViewController.h"

@interface SettingsViewController () {
    BOOL isFBConncted;
    NSString *fbProfile;
}
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@""
                                      style:UIBarButtonItemStylePlain
                                     target:nil
                                     action:nil] autorelease];
    
    
    [self.navigationItem setTitle:NSLocalizedString(@"titleSettings", nil)];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{
                              UITextAttributeFont:NAVBAR_FONT,
                              UITextAttributeTextColor:NAVBAR_TITLE_COLOR,
                              }];
    
    isFBConncted = [Utility isFacebookConnected];
}

#pragma mark - TableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(isFBConncted) return 1;
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if(isFBConncted) return 2;
            return 1;
            break;
        case 1:
            return 2;
            break;
        default:
            break;
    }
    
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if(isFBConncted) return NSLocalizedString(@"sectionFindFriends", nil);
            return NSLocalizedString(@"sectionConnectFacebook", nil);
            break;
        case 1:
            return NSLocalizedString(@"sectionFindFriends", nil);
            break;
        default:
            break;
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TextImageCellId";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:10];
    UILabel *lblText = (UILabel *)[cell viewWithTag:11];
    
    NSString *icon = @"";
    NSString *text = @"";
    

    if ([indexPath row] == 0) {
        if (!isFBConncted && indexPath.section == 0) {
            icon = @"fb.png";
            text = NSLocalizedString(@"lblConnectFacebook", nil);
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            icon = @"fb_pc.png";
            text = NSLocalizedString(@"lblFFFacebook", nil);
        }
    } else {
        icon = @"addr_book.png";
        text = NSLocalizedString(@"lblFFAddressBook",nil);
    }
    
    //Setting cell details
    [iconView setImage:[UIImage imageNamed:icon]];
    [lblText setText:text];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (!isFBConncted && section == 0) return NSLocalizedString(@"footerFacebook", nil);
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            if (isFBConncted) [self performSegueWithIdentifier:@"SettingsToMatching" sender:indexPath];
            else {
                [self connectFacebook];
            }
            break;
        case 1:
            if (indexPath.row == 0 && !isFBConncted) {
                UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageConnectFacebook", nil) cancelButtonTitle:NSLocalizedString(@"No", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil),nil];
                
                [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
                    if (didCancel) {
                        return;
                    } else {
                        [self connectFacebook];
                    }
                }];
            } else {
                [self performSegueWithIdentifier:@"SettingsToMatching" sender:indexPath];
            }
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SettingsToMatching"]) {
        [(MatchingViewController *)segue.destinationViewController setType:((NSIndexPath *)sender).row];
    }
    
}


#pragma mark - Facebook connection methods

/*************FACEBOOK CONNECTION***************/

- (void)connectFacebook {
    if (!FBSession.activeSession.isOpen) {
        [self openSession];
    }
}


- (void)getUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 
                 NSDictionary *dict = (NSDictionary *)user;

                 NSString *gender = [Utility encryptString:[dict valueForKey:@"gender"]];
                 NSString *birthday = [Utility encryptString:user.birthday];
                 fbProfile = [user.id retain];
                 NSString *profile_id = [Utility encryptString:fbProfile];
                 
                 NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
                 NSString *token = [Utility encryptString:[Utility getDeviceToken]];
                 NSString *session = [Utility encryptString:[Utility getSession]];
                 NSString *method = [Utility encryptString:SERVICE_CONNECT_FACEBOOK];
                 
                 //Creo la stringa di inserimento
                 NSString *str = [URL_SERVER stringByAppendingString:@"request.php"];
                 
                 //Start parser thread
                 ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
                 [request setPostValue:profile_id forKey:@"facebook"];
                 [request setPostValue:device forKey:@"device"];
                 [request setPostValue:token forKey:@"token"];
                 [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
                 [request setPostValue:session forKey:@"session"];
                 [request setPostValue:birthday forKey:@"birthday"];
                 [request setPostValue:gender forKey:@"gender"];
                 [request setPostValue:method forKey:@"method"];
                 [request setDelegate:self];
                 [request startAsynchronous];
             } else {
                 //Error
                 [self stopModeLoading];
             }
         }];
    } else {
        
    }
}



/*****NEW APPROCH*****/

#pragma mark -
#pragma mark - FB state changed NEW

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            [self getUserDetails];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [FBSession.activeSession closeAndClearTokenInformation];
            [self stopModeLoading];
            
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Connection error", nil)
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];

        [self stopModeLoading];
        [alertView show];
    }
}

- (void)openSession
{
    [self startModeLoadingWithText:NSLocalizedString(@"Connect", nil)];
    
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"email", nil];
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}
/*************/


- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self stopModeLoading];
    
    if (request.responseStatusCode == 200) {
        NSString *responseString = [request responseString];
        NSDictionary *responseDict = [responseString JSONValue];
        
        NSString *logged = [responseDict valueForKey:@"logged"];
        
        if([logged isEqualToString:@"1"]) {
            
            //Accesso avvenuto
            NSString *response = [responseDict valueForKey:@"response"];

            if([response isEqualToString:@"-1"]) {
                
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                [FBSession.activeSession closeAndClearTokenInformation];
                
            } else if([response isEqualToString:@"FbUserExists"]) {
                
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageFbUserExists", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                [FBSession.activeSession closeAndClearTokenInformation];
                
            } else if([response isEqualToString:@"1"]) {
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                
                HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
                
                // Set custom view mode
                HUD.mode = MBProgressHUDModeCustomView;
                
                HUD.delegate = self;
                HUD.labelText = NSLocalizedString(@"Facebook connected!", nil);
                
                [HUD show:YES];
                [HUD hide:YES afterDelay:1.5];
                
                [Utility setDefaultValue:fbProfile forKey:USER_FACEBOOK_LOGIN];
                isFBConncted = [Utility isFacebookConnected];
                [self.tableView reloadData];
            }
            
        } else if([logged isEqualToString:@"OLDappVersion"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageVersionOld", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [FBSession.activeSession closeAndClearTokenInformation];
        } else if([logged isEqualToString:@"-1"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
        } else if([logged isEqualToString:@"0"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"errorSession", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [FBSession.activeSession closeAndClearTokenInformation];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:NSLocalizedString(@"messageConnectionError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self stopModeLoading];
    NSError *error = [request error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [FBSession.activeSession closeAndClearTokenInformation];
    
}



@end
