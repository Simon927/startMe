
//
//  LoginViewController.m
//  eventbook
//
//  Created by Matteo Gobbi on 01/12/11.
//  Copyright (c) 2011 Matteo Gobbi - Ingegnere Informatico libero professionista. All rights reserved.
//

#import "MasterViewController.h"
#import "JoinViewController.h"

@interface MasterViewController () {
    BOOL chooseImage;
}
    -(void)initializeView;
    -(void)loginWithSendConfirm:(BOOL)send;
    -(void)getUserDetails;
@end

@implementation MasterViewController

@synthesize tb;

- (void)awakeFromNib
{
    [super awakeFromNib];

    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture release];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    NSString *email = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:11]).text;
    NSString *password = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:11]).text;
    
    if(![email isEqualToString:@""] && ![password isEqualToString:@""]) {
        [self login];
    }
}


-(void)initializeView {
    [self.navigationController setNavigationBarHidden:YES];
    
    [tb setBackgroundColor:[UIColor clearColor]];
    
    [lblTitle setFont:[UIFont fontWithName:APP_TITLE_FONT size:33]];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //Check if there is an active session
    if(![[Utility getSession] isEqualToString:@""]) {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // Yes, so just open the session (this won't display any UX).
            //Login with new facebook session
            [self openSession];
        } else {
            //Use the actual session
            [self goToCommunity];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /***Set localized language***/
    [btJoinFB setTitle:NSLocalizedString(@"btJoinFB", "Button in the soryboard to login with FB") forState:UIControlStateNormal];
    [btSignIn setTitle:NSLocalizedString(@"btSignIn", "Button in the soryboard to Sign up") forState:UIControlStateNormal];
    [btResetPass setTitle:NSLocalizedString(@"btResetPass", "Button in the soryboard to reset password") forState:UIControlStateNormal];
    /*****/
 
    dman = [DataManager getInstance];
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@""
                                      style:UIBarButtonItemStylePlain
                                     target:nil
                                     action:nil] autorelease];
    
    [self initializeView];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma -
#pragma Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"MasterCellIdentifier";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:10];
    UITextField *textField = (UITextField *)[cell viewWithTag:11];
    
    textField.delegate = self;
    
    NSString *icon = @"";
    NSString *placeholder = @"";
    

    if ([indexPath row] == 0) {
        icon = @"user.png";
        placeholder = NSLocalizedString(@"E-mail or Username", nil);
        
        textField.returnKeyType = UIReturnKeyNext;
    } else {
        icon = @"key.png";
        placeholder = NSLocalizedString(@"Password",nil);
        
        textField.returnKeyType = UIReturnKeyJoin;
        textField.secureTextEntry = YES;
    }
    
    //Setting cell details
    [iconView setImage:[UIImage imageNamed:icon]];
    [textField setAttributedPlaceholder:[[[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: APP_PLACEHOLDER_TEXT_COLOR}] autorelease]];
    
    return cell;
}


#pragma mark -
#pragma mark - Text Field Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // Determine the row number of the active UITextField in which "return" was just pressed.
    id cellContainingFirstResponder = textField.superview.superview.superview;
    NSInteger rowOfCellContainingFirstResponder = [tb indexPathForCell:cellContainingFirstResponder].row ;
    NSInteger nextTag = rowOfCellContainingFirstResponder+1;
    NSIndexPath* indexPathOfNextCell = [NSIndexPath indexPathForRow:nextTag inSection:0] ;
    UITableViewCell* nextCell = (UITableViewCell *)[tb cellForRowAtIndexPath:indexPathOfNextCell] ;
                                  
    // Try to find next responder
    if (nextCell) {
        // Found next responder, so set it.
        [(UITextField *)[nextCell viewWithTag:11] becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
        [self login];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}


#pragma mark -
#pragma mark - My Methods

-(void)login {
    [self.view endEditing:YES];
    
    [self loginWithSendConfirm:NO];
}


-(void)loginWithSendConfirm:(BOOL)send {
    [self startModeLoadingWithText:NSLocalizedString(@"Login", nil)];
    
    NSString *email = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:11]).text;
    NSString *password = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:11]).text;
    
    email = [Utility encryptString:email];
    password = [Utility encryptString:password];
    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    language = [Utility encryptString:language];
    
    NSString *strSend = @"false";
    if(send) strSend = @"true";
    
    //POST
    NSString *str = [URL_SERVER stringByAppendingString:@"login.php"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:device forKey:@"device"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:language forKey:@"lang"];
    [request setPostValue:strSend forKey:@"send_confirm"];
    [request setDelegate:self];
    [request startAsynchronous];

}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self stopModeLoading];
    
    if (request.responseStatusCode == 200) {
        NSString *responseString = [request responseString];
        NSDictionary *responseDict = [responseString JSONValue];
        
        NSString *login = [responseDict valueForKey:@"login"];
        
        if([login isEqualToString:@"1"] || [login isEqualToString:@"4"]) {
            
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
            
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
            
            HUD.delegate = self;
            HUD.labelText = NSLocalizedString(@"Access permitted!", nil);
            
            [HUD show:YES];
            [HUD hide:YES afterDelay:1.5];
            
            
            //Login permitted
            NSString *user_id = [responseDict valueForKey:@"user_id"];
            NSString *session = [responseDict valueForKey:@"session"];
            NSString *facebook = [responseDict valueForKey:@"facebook"];
            NSString *image = [responseDict valueForKey:@"img_profile"];
            NSString *nickname = [responseDict valueForKey:@"nickname"];
            
            user_id = [Utility decryptString:user_id];
            session = [Utility decryptString:session];
            facebook = [Utility decryptString:facebook];
            image = [Utility decryptString:image];
            nickname = [Utility decryptString:nickname];
            
            if(![session isEqualToString:@""] && session != nil) {
                [Utility setDefaultValue:user_id forKey:USER_ID];
                [Utility setDefaultValue:session forKey:USER_SESSION];
                [Utility setDefaultValue:facebook forKey:USER_FACEBOOK_LOGIN];
                [Utility setDefaultValue:nickname forKey:USER_NICKNAME];
            }
            
            if(image) {
                UIImage *im = [Utility getCachedImageFromPath:[URL_SERVER stringByAppendingString:PATH_IMAGES_PROFILES] withName:image];
                [Utility setDefaultObject:UIImageJPEGRepresentation(im, 1.0) forKey:USER_IMG_PROFILE];
            }
            
            //Reset all param for the new logged user
            [[DataManager getInstance] resetParam];
            
            chooseImage = [login isEqualToString:@"4"];
            
            [self goToCommunity];
            
            return;
            
        } else if([login isEqualToString:@"-1"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else if([login isEqualToString:@"0"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"errorAccountData", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else if([login isEqualToString:@"3"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageConfirmEmail", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else if([login isEqualToString:@"2"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"errorConfirmEmail", nil) delegate:self cancelButtonTitle:@"No, grazie" otherButtonTitles:@"Invia",nil];
            alert.tag = 1;
            [alert show];
            [alert release];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:NSLocalizedString(@"messageConnectionError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
    [dman logout];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [dman logout];
    [self stopModeLoading];
    NSError *error = [request error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
}


-(void)goToCommunity {
    
    //Reset field user and pass
    ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:11]).text = @"";
    ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:11]).text = @"";
     
    //Go to community
    [self performSegueWithIdentifier:@"MasterToCommunity" sender:self];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1:
            if(buttonIndex == 1) {
                //Not used
                [self loginWithSendConfirm:YES];
            }
            break;
            
        default:
            break;
    }
}


//Disable command and active loading (override)
-(void)setModeLoading:(BOOL)active withText:(NSString *)text {
    [super setModeLoading:active withText:text];
    
    //Set extra controls (ex. Button item on navBar)
    btLogin.enabled = !active;
}



- (IBAction)resetPass:(id)sender {
    
    NSString *email = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:11]).text;
    if ([[email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"errorResetPass", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    } else {
        email = [Utility encryptString:email];
        
    [self startModeLoadingWithText:NSLocalizedString(@"Reset",nil)];
        
    NSString *str = [URL_SERVER stringByAppendingString:@"forgot_pass.php"];
        
        __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
        [request setPostValue:email forKey:@"email"];
        
        [request setCompletionBlock:^{
            
            if (request.responseStatusCode == 200) {
                NSString *responseString = [request responseString];
                NSDictionary *responseDict = [responseString JSONValue];
                
                NSString *response = [responseDict valueForKey:@"response"];
                
                if([response isEqualToString:@"-1"]) {
                    
                    //Show alert
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    
                } else if([response isEqualToString:@"USERnotExists"]) {
                    
                    //Show alert
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"errorUserNotExists", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    
                } else if([response isEqualToString:@"EMAILerror"]) {
                    
                    //Show alert
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil)  message:NSLocalizedString(@"errorMail", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    
                } else if([response isEqualToString:@"1"]) {
                    //Show alert
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageResetPass", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:NSLocalizedString(@"messageConnectionError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                
            }
            
            
            [self stopModeLoading];
        }];
        [request setFailedBlock:^{
            NSError *error = [request error];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errore di connessione" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            [self stopModeLoading];
        }];
        
        [request startAsynchronous];
    }
}

- (IBAction)joinFB:(id)sender {
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
                 
                 //Get info from facebook: if the user already exist, there isn't problem
                 NSDictionary *dict = (NSDictionary *)user;
                 
                 //Temp nickname
                 NSString *nickname = user.username;
                 [Utility setDefaultValue:nickname forKey:USER_TEMPFB_NICKNAME];
                 nickname = [Utility encryptString:nickname];
                 
                 NSString *name = [Utility encryptString:user.first_name];
                 NSString *surname = [Utility encryptString:user.last_name];
                 NSString *gender = [Utility encryptString:[dict valueForKey:@"gender"]];
                 NSString *birthday = [Utility encryptString:user.birthday];
                 NSString *profile_id = user.id;
                 profile_id = [Utility encryptString:profile_id];
                 NSString *email = [Utility encryptString:[dict valueForKey:@"email"]];

                 NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
                 NSString *token = [Utility encryptString:[Utility getDeviceToken]];

                 NSString *str = [URL_SERVER stringByAppendingString:@"fb_login.php"];
                 
                 NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
                 language = [Utility encryptString:language];
                 
                 //Start parser thread
                 ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
                 [request setPostValue:name forKey:@"name"];
                 [request setPostValue:surname forKey:@"surname"];
                 [request setPostValue:profile_id forKey:@"facebook"];
                 [request setPostValue:device forKey:@"device"];
                 [request setPostValue:token forKey:@"token"];
                 [request setPostValue:language forKey:@"lang"];
                 [request setPostValue:birthday forKey:@"birthday"];
                 [request setPostValue:gender forKey:@"gender"];
                 [request setPostValue:email forKey:@"email"];
                 [request setDelegate:self];
                 [request startAsynchronous];
             } else {
                 [[DataManager getInstance] logout];
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
        
        [[DataManager getInstance] logout];
        [self stopModeLoading];
        [alertView show];
    }
}

- (void)openSession
{
    [self startModeLoadingWithText:NSLocalizedString(@"Login", nil)];
    
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

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"MasterToCommunity"]) {
        CommunityViewController *vc = (CommunityViewController *)segue.destinationViewController;
        vc.chooseImage = chooseImage;
        chooseImage = NO;
    }
    
}


//The event handling method
- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [self.view endEditing:YES];
    }
}

-(void)dealloc {
    [btJoinFB release];
    [tb release];
    [btSignIn release];
    [lblTitle release];
    [btResetPass release];
    [super dealloc];
}

@end
