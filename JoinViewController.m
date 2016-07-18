//
//  JoinViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 20/12/12.
//  Copyright (c) 2012 Matteo Gobbi. All rights reserved.
//

#import "JoinViewController.h"
#import "MasterViewController.h"
#import "ExploreViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation JoinViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //The setup code (in viewDidLoad in your view controller)
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];

    btJoin = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(join:)] autorelease];
    [self.navigationItem setRightBarButtonItem:btJoin];
}

-(void)viewDidLoad {
    /***Localized string nib***/
    [self.navigationItem setTitle:NSLocalizedString((_user) ? @"titleEditProfile" : @"titleSignUp", nil)];
    /********/
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
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDelegate and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"sectionProfile",nil);
            break;
        case 1:
            return NSLocalizedString(@"sectionEmail",nil);
        case 2:
            return NSLocalizedString(@"sectionPassword",nil);
        default:
            break;
    }
    
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"JoinDoubleCellIdentifier";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RoundCornerImageView *iconView = (RoundCornerImageView *)[cell viewWithTag:10];
    [iconView setCircleMask];
    [iconView setBorderWidth:1.0];
    [iconView setBorderColor:[UIColor colorWithWhite:0.84 alpha:1.0]];
    
    UITextField *textField1 = (UITextField *)[cell viewWithTag:11];
    UITextField *textField2 = (UITextField *)[cell viewWithTag:12];
    
    NSString *icon = @"";
    NSString *placeholder1 = @"";
    NSString *placeholder2 = @"";
    
    textField1.delegate = self;
    textField2.delegate = self;
    
    switch (indexPath.section) {
        case 0: {
            icon = @"user.png";
            
            placeholder1 = NSLocalizedString(@"First Name",nil);
            textField1.keyboardType = UIKeyboardTypeDefault;
            textField1.returnKeyType = UIReturnKeyNext;
            textField1.autocapitalizationType = UITextAutocapitalizationTypeWords;
            if(_user) [textField1 setText:_user.name];
        
            placeholder2 = NSLocalizedString(@"Last Name",nil);
            textField2.keyboardType = UIKeyboardTypeDefault;
            textField2.returnKeyType = UIReturnKeyNext;
            textField2.autocapitalizationType = UITextAutocapitalizationTypeWords;
            if(_user) [textField2 setText:_user.surname];
            break;

        }
    
        case 1: {
            
            icon = @"mail.png";
            placeholder1 = NSLocalizedString(@"E-mail",nil);
            textField1.keyboardType = UIKeyboardTypeEmailAddress;
            textField1.returnKeyType = UIReturnKeyNext;
            textField1.autocapitalizationType = UITextAutocapitalizationTypeNone;
            if(_user) [textField1 setText:_user.email];
            
            placeholder2 = NSLocalizedString(@"Confirm e-mail",nil);
            textField2.keyboardType = UIKeyboardTypeEmailAddress;
            textField2.returnKeyType = UIReturnKeyNext;
            textField2.autocapitalizationType = UITextAutocapitalizationTypeNone;
            if(_user) [textField2 setText:_user.email];
            break;

        }
            
        case 2: {
            
            icon = @"key.png";
            
            placeholder1 = (_user) ? NSLocalizedString(@"New Password",nil) : NSLocalizedString(@"Password",nil);
            textField1.keyboardType = UIKeyboardTypeDefault;
            textField1.returnKeyType = UIReturnKeyNext;
            textField1.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField1.secureTextEntry = YES;
            
            placeholder2 = NSLocalizedString(@"Confirm Password",nil);
            textField2.keyboardType = UIKeyboardTypeDefault;
            textField2.returnKeyType = UIReturnKeyDone;
            textField2.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField2.secureTextEntry = YES;
            break;
            
        }

    }
    
    //Setting cell details
    [iconView setImage:[UIImage imageNamed:icon]];
    [textField1 setAttributedPlaceholder:[[[NSAttributedString alloc] initWithString:placeholder1 attributes:@{NSForegroundColorAttributeName: APP_PLACEHOLDER_TEXT_COLOR}] autorelease]];
    [textField2 setAttributedPlaceholder:[[[NSAttributedString alloc] initWithString:placeholder2 attributes:@{NSForegroundColorAttributeName: APP_PLACEHOLDER_TEXT_COLOR}] autorelease]];
    
    
    return cell;
    
}

/******/

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    id cell = textField.superview.superview.superview;
    NSInteger section = [tb indexPathForCell:cell].section ;
    [tb setContentOffset:CGPointMake(0, 0) animated:YES];
    [myScroll setContentOffset:CGPointMake(0, section*(150)-myScroll.contentInset.top) animated:YES];
    
    return YES;
}


- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    // Determine the row number of the active UITextField in which "return" was just pressed.
    id cell = textField.superview.superview.superview;
    NSInteger section = [tb indexPathForCell:cell].section ;
    
    UITableViewCell *nextCell = cell;
    if(textField.tag == 12) {
        NSIndexPath* indexPathOfNextCell = [NSIndexPath indexPathForRow:0 inSection:++section];
        nextCell = (UITableViewCell *)[tb cellForRowAtIndexPath:indexPathOfNextCell];
    }
       
    
    if(textField.tag == 12) {
        if (section <= 2) {
            [(UITextField *)[nextCell viewWithTag:11] becomeFirstResponder];
            return YES;
        }
    } else {
        [(UITextField *)[nextCell viewWithTag:12] becomeFirstResponder];
        return YES;
    }
    
    [tb setContentOffset:CGPointMake(0, 0) animated:NO];
    [myScroll setContentOffset:CGPointMake(0, -myScroll.contentInset.top) animated:YES];
    [textField resignFirstResponder];
    [self join:self];


    return YES ;
}


#pragma mark - My Methods


-(void)join:(id)sender {
    [self startModeLoadingWithText:(_user) ? NSLocalizedString(@"Refresh", nil) : NSLocalizedString(@"Sign up", nil)];
    
    NSString *name = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:11]).text;
    NSString *surname = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:12]).text;
    NSString *email = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] viewWithTag:11]).text;
    NSString *emailC = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] viewWithTag:12]).text;
    NSString *password = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] viewWithTag:11]).text;
    NSString *passwordC = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] viewWithTag:12]).text;
     
    
    name = [Utility encryptString:name];
    surname = [Utility encryptString:surname];
    email = [Utility encryptString:email];
    emailC = [Utility encryptString:emailC];
    password = [Utility encryptString:password];
    passwordC = [Utility encryptString:passwordC];
    
    NSString *str = [URL_SERVER stringByAppendingString:(_user) ? @"edit_profile.php" : @"register.php"];
    
    //Start parser thread
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setPostValue:email forKey:@"email"];
    [request setPostValue:emailC forKey:@"emailC"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:passwordC forKey:@"passwordC"];
    [request setPostValue:name forKey:@"name"];
    [request setPostValue:surname forKey:@"surname"];
    
    if(_user) {
        NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
        NSString *session = [Utility encryptString:[Utility getSession]];
        NSString *token = [Utility encryptString:[Utility getDeviceToken]];
        
        [request setPostValue:device forKey:@"device"];
        [request setPostValue:session forKey:@"session"];
        [request setPostValue:token forKey:@"token"];
        [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
    }
    
    [request setDelegate:self];
    [request startAsynchronous];
}


//Login parser end
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self stopModeLoading];
    if (request.responseStatusCode == 200) {
        NSString *responseString = [request responseString];
        NSDictionary *responseDict = [responseString JSONValue];
        
        //If i'm editing profile check if i'm logged
        if(_user) {
            NSString *logged = [responseDict valueForKey:@"logged"];
        
            if([logged isEqualToString:@"OLDappVersion"]) {
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageVersionOld", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                [[DataManager getInstance] logout];
                [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
            } else if([logged isEqualToString:@"-1"]) {
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                return;
            } else if([logged isEqualToString:@"0"]) {
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[NSString stringWithFormat:NSLocalizedString(@"errorSession", nil), APP_TITLE] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                [[DataManager getInstance] logout];
                [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
                
                return;
            }
        }
        
        
        NSString *response = [responseDict valueForKey:@"join"];
        
        NSString *message = [[NSString alloc] init];
    
        if([response isEqualToString:@"OKjoin"]) {
            //Get masterViewController
            if(!_user) {
                [self login];
            } else {
                NSString *name = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:11]).text;
                NSString *surname = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:12]).text;
                NSString *email = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] viewWithTag:11]).text;
                
                [_user setName:name];
                [_user setSurname:surname];
                [_user setEmail:email];
                
                [self.navigationController popViewControllerAnimated:YES];
                ExploreViewController *profileView = (ExploreViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 1];
                
                [profileView.tableList reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            [message release];
            
            return;
            
        } else if([response isEqualToString:@"KOjoin"]) {
            if(_user)
                message = NSLocalizedString(@"errorEditAccount", nil);
            else
                message = NSLocalizedString(@"errorCreateAccount", nil);
        } else if([response isEqualToString:@"INVALIDname"]) {
            message = NSLocalizedString(@"INVALIDname", nil);
        } else if([response isEqualToString:@"INVALIDsurname"]) {
            message = NSLocalizedString(@"INVALIDsurname", nil);
        } else if([response isEqualToString:@"EXISTemail"]) {
            message = NSLocalizedString(@"EXISTemail", nil);
        } else if([response isEqualToString:@"INVALIDpass"]) {
            message = NSLocalizedString(@"INVALIDpass", nil);
        } else if([response isEqualToString:@"INVALIDmail"]) {
            message = NSLocalizedString(@"INVALIDmail", nil);
        } else if([response isEqualToString:@"INEQUALpass"]) {
            message = NSLocalizedString(@"INEQUALpass", nil);
        } else if([response isEqualToString:@"INEQUALmail"]) {
            message = NSLocalizedString(@"INEQUALmail", nil);
        }
        
        //Show alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        [message release];        
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:NSLocalizedString(@"messageConnectionError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self stopModeLoading];
    NSError *error = [request error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

//Disable command and active loading
-(void)setModeLoading:(BOOL)active withText:(NSString *)text {
    [super setModeLoading:active withText:text];
    
    //Set extra controls (ex. Button item on navBar)
    btJoin.enabled = !active;
}


//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [myScroll setContentOffset:CGPointMake(0, -myScroll.contentInset.top) animated:YES];
    [self.view endEditing:YES];
}



-(void)login {
    //Launch login from loginViewController
    
    //Get masterViewController
    MasterViewController *master = (MasterViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    //Get value from self
    NSString *email = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] viewWithTag:11]).text;
    NSString *password = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] viewWithTag:11]).text;
    
    //Set field
    ((UITextField *)[[master.tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:11]).text = email;
    ((UITextField *)[[master.tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:11]).text = password;
    
    //Login
    [master login];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)dealloc {
    [_user release];
    [super dealloc];
}

@end
