//
//  MatchingViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 17/10/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#define NO_MATCHING ([arrMatchedUsers count] == 0)
#define TAG_BUTTON_FOLLOW 13

#import "MatchingViewController.h"
#import "User.h"
#import "Followed.h"

@interface MatchingViewController () {
    NSString *strPeople;
    NSMutableArray *arrPeople;
    NSMutableArray *arrMatchedUsers;
}
@end

@implementation MatchingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@""
                                      style:UIBarButtonItemStylePlain
                                     target:nil
                                     action:nil] autorelease];
    
    
    [self.navigationItem setTitle:(_type == kTypeMatchingFacebook) ? NSLocalizedString(@"titleMatchingFacebook", nil) : NSLocalizedString(@"titleMatchingAddressBook", nil)];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{
                              UITextAttributeFont:NAVBAR_FONT,
                              UITextAttributeTextColor:NAVBAR_TITLE_COLOR,
                              }];
    
    arrMatchedUsers = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self getStringContactsFrom:_type];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(NO_MATCHING) return 1;
    return [arrMatchedUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(NO_MATCHING) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setText:NSLocalizedString(@"messageNoMatching", nil)];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.textLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
        return cell;
    }
    
    User *u = [arrMatchedUsers objectAtIndex:indexPath.row];
    
    //Rilascio la cella profilo
    static NSString *CellIdentifier = @"UserCellId";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RoundCornerImageView *imgProfileView = (RoundCornerImageView *)[cell viewWithTag:10];
    [imgProfileView setCircleMask];
    UILabel *name = (UILabel *)[cell viewWithTag:11];
    UILabel *nickname = (UILabel *)[cell viewWithTag:12];
    UIButton *btFollow = (UIButton *)[cell viewWithTag:TAG_BUTTON_FOLLOW];
    
    [name setText:[NSString stringWithFormat:@"%@ %@",u.name,u.surname]];
    [nickname setText:u.nickname];
    [imgProfileView setImage:u.imgProfile];
    [btFollow setSelected:u.is_followed];
    [btFollow addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
    [btFollow setTitle:NSLocalizedString(@"btFollow", nil) forState:UIControlStateNormal];
    [btFollow setTitle:NSLocalizedString(@"btUnfollow", nil) forState:UIControlStateSelected];
    
    return cell;
}


#pragma mark - my methods

- (void)match {
    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
    NSString *session = [Utility encryptString:[Utility getSession]];
    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
    NSString *type = [Utility encryptString:[NSString stringWithFormat:@"%d",_type]];
    NSString *str_friends = [Utility encryptString:strPeople];
    
    NSString *str = [URL_SERVER stringByAppendingString:@"match_friends.php"];
    
    //Start parser thread
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setPostValue:device forKey:@"device"];
    [request setPostValue:session forKey:@"session"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
    [request setPostValue:type forKey:@"type"];
    [request setPostValue:str_friends forKey:@"str_friends"];
    [request setDelegate:self];
    [request startAsynchronous];
}


//Login parser end
- (void)requestFinished:(ASIHTTPRequest *)request
{
    //Only if controller isn't presented with curl
    [self stopModeLoading];
    if (request.responseStatusCode == 200) {
        NSString *responseString = [request responseString];
        NSDictionary *responseDict = [responseString JSONValue];
        
        NSString *logged = [responseDict valueForKey:@"logged"];
        
        if([logged isEqualToString:@"1"]) {
            
            
            //Controllo se ci sono nuovi followed
            NSArray *new_followed = (NSArray *)[responseDict valueForKey:@"new_followed"];
            if([new_followed count] > 0) {
                
                NSMutableArray *followed = [NSMutableArray arrayWithArray:[Utility getFollowed]];
                
                for(NSDictionary *f in new_followed) {
                    Followed *new_f = [[Followed alloc] initWithEncryptedDictonary:f];
                    
                    //If exists
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"id LIKE '%@'", new_f.id_relation]];
                    NSArray *match = [followed filteredArrayUsingPredicate:predicate];
                    if([match count] > 0) {
                        if(!new_f.is_followed)
                            [followed removeObjectsInArray:match];
                        else
                            [followed replaceObjectAtIndex:[followed indexOfObject:[match objectAtIndex:0]] withObject:[new_f toDictionary]];
                    } else {
                        if(new_f.is_followed)
                            [followed addObject:[new_f toDictionary]];
                    }
                    
                    [new_f release];
                }
                [Utility setDefaultObject:followed forKey:FOLLOWED_DOWNLOADED];
            }
            //*****//
            
            
            //Session valid
            NSString *response = [responseDict valueForKey:@"response"];
            
            if([response isEqualToString:@"-1"]) {
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else if([response isEqualToString:@"1"]) {
                
                NSMutableArray *matchedUsers = [responseDict valueForKey:@"arr_friends"];
                
                for(NSDictionary *mu in matchedUsers) {
                    User *u = [[User alloc] initWithEncryptedDictonary:mu];
                    [arrMatchedUsers addObject:u];
                 
                    //Deleting
                    /*
                    NSString *query = [NSString stringWithFormat:@"self.%@ CONTAINS '%@'",(_type == kTypeMatchingAddressBook) ? @"email" : @"id", (_type == kTypeMatchingAddressBook) ? u.email : u.facebook];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
                    NSArray *arrM = [arrPeople filteredArrayUsingPredicate:predicate];
                    [arrPeople removeObjectsInArray:arrM];
                     */
                     
                }
                
                //Update tabella and stop mode loading
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    [self stopModeLoading];
                }];
                
                [self.tableView reloadData];
                
                [CATransaction commit];
            }
        } else if([logged isEqualToString:@"OLDappVersion"]) {
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
        } else if([logged isEqualToString:@"0"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[NSString stringWithFormat:NSLocalizedString(@"errorSession", nil), APP_TITLE] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [[DataManager getInstance] logout];
            [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:NSLocalizedString(@"messageConnectionError", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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


- (void)getStringContactsFrom:(TypeMatching)typeMatching {
    
    //Start mode loading
    [self startModeLoadingWithText:NSLocalizedString(@"Matching", nil)];
    
    //Array to send
    strPeople = [[NSString alloc] initWithString:@";"];
    
    if (typeMatching == kTypeMatchingAddressBook) {

        __block BOOL accessGranted = NO;
        
        NSError *error = nil;
        ABAddressBookRef _addressBookRef = ABAddressBookCreateWithOptions(NULL, (CFErrorRef *)&error);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(_addressBookRef, ^(bool granted, CFErrorRef error) {
                // This requests access the first time, then adds the contact
                //I can't access to the address book
                
                if(!granted) {
                    [self stopModeLoading];
                    return;
                }
                
                CFRelease(_addressBookRef);
                
                [self getContactFromAddressBook];
                [self match];
                
            });
            return;
        } else if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            accessGranted = YES;
        }
        
        if(!accessGranted) {
            [self stopModeLoading];
            return;
        }
        
        CFRelease(_addressBookRef);
        
        [self getContactFromAddressBook];
        [self match];
        
    } else {
        //Get from facebook
        FBRequest* friendsRequest = [FBRequest requestForMyFriends];
        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                      NSDictionary* result,
                                                      NSError *error) {
            
            arrPeople = [[result objectForKey:@"data"] retain];

            for (NSDictionary<FBGraphUser>* friend in arrPeople) {
                strPeople = [strPeople stringByAppendingFormat:@"%@;",friend.id];
            }
            
            [self match];
        }];
    }
}


-(void)getContactFromAddressBook {
    NSError *error = nil;
    ABAddressBookRef _addressBookRef = ABAddressBookCreateWithOptions(NULL, (CFErrorRef *)&error);
    
    NSArray *arrRubric = (NSArray *)ABAddressBookCopyArrayOfAllPeople(_addressBookRef);
    
    // now iterate though all the records and suck out phone numbers
    for (id record in arrRubric)
    {
        
        ABMultiValueRef emailProperty = ABRecordCopyValue((ABRecordRef)record, kABPersonEmailProperty);
        
        //Create string with email address
        for(CFIndex j = 0; j < ABMultiValueGetCount(emailProperty); j++)
        {
            //Address
            CFStringRef emailAddressRef = ABMultiValueCopyValueAtIndex(emailProperty, j);
            NSString *emailAddress = (NSString *)emailAddressRef;
            
            /****GESTISCO ARRAY DA MANDARE*****/
            strPeople = [strPeople stringByAppendingFormat:@"%@;",emailAddress];
            /********************************/
            
            //Optiona: add person to arrPeople
            //....
            
            [emailAddress release];
        }
    }
    
    CFRelease(_addressBookRef);
}


- (void)touchMyButton:(UIButton*)button event:(UIEvent*)event
{
    switch (button.tag) {
        case TAG_BUTTON_FOLLOW: {
            
            //It's the like button
            //Set Button
            [button setSelected:!button.selected];
            
            NSIndexPath* indexPath = [self.tableView indexPathForRowAtPoint:
                                      [[[event touchesForView:button] anyObject]
                                       locationInView:self.tableView]];
            User *u = (User *)[arrMatchedUsers objectAtIndex:indexPath.row];
            [u setIs_followed:button.selected];
            
            //Start parser thread
            NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
            NSString *session = [Utility encryptString:[Utility getSession]];
            NSString *token = [Utility encryptString:[Utility getDeviceToken]];
            NSString *followed_id = [Utility encryptString:u.user_id];
            NSString *value = [Utility encryptString:[NSString stringWithFormat:@"%d", button.selected]];
            
            //Attach last followed received
            NSString *followed_last_refresh = [Utility getDefaultValueForKey:FOLLOWED_LAST_REFRESH];
            followed_last_refresh = (![followed_last_refresh isEqualToString:@""]) ? [Utility encryptString:followed_last_refresh] : [Utility encryptString:@"0"];
            //***//
            
            NSString *str = [URL_SERVER stringByAppendingString:@"follow.php"];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
            [request setPostValue:device forKey:@"device"];
            [request setPostValue:session forKey:@"session"];
            [request setPostValue:token forKey:@"token"];
            [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
            [request setPostValue:followed_id forKey:@"followed_id"];
            [request setPostValue:value forKey:@"value"];
            [request setPostValue:followed_last_refresh forKey:@"followed_last_refresh"];
            [request setMethod:SERVICE_FOLLOW];
            [request setDelegate:self];
            [request startAsynchronous];
            
            break;
        }
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end
