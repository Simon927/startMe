//
//  NotificationViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 19/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "ListPersonViewController.h"
#import "ExploreViewController.h"
#import "User.h"

@implementation ListPersonViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _arrUsers = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.navigationItem.backBarButtonItem setTitle:(_nickname && ![_nickname isEqualToString:@""]) ? [@"@" stringByAppendingString:_nickname] : @""];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{
                              UITextAttributeFont:NAVBAR_FONT,
                              UITextAttributeTextColor:NAVBAR_TITLE_COLOR,
                              }];
    
    switch (_listType) {
        case kListTypeFollowers:
            [self.navigationItem setTitle:NSLocalizedString(@"titleFollower", nil)];
            break;
        case kListTypeFollowing:
            [self.navigationItem setTitle:NSLocalizedString(@"titleFollowing", nil)];
            break;
        case kListTypeLike:
            [self.navigationItem setTitle:NSLocalizedString(@"titleLike", nil)];
            break;
        default:
            break;
    }
    
    [self refresh];
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
    return [_arrUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RoundCornerImageView *imgProfileView = (RoundCornerImageView *)[cell viewWithTag:10];
    [imgProfileView setCircleMask];
    UILabel *name = (UILabel *)[cell viewWithTag:11];
    UILabel *nickname = (UILabel *)[cell viewWithTag:12];
    
    User *user = [_arrUsers objectAtIndex:indexPath.row];
    
    [name setText:[NSString stringWithFormat:@"%@ %@",user.name,user.surname]];
    [nickname setText:user.nickname];
    [imgProfileView setImage:user.imgProfile];
    
    return cell;
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    User *u = [_arrUsers objectAtIndex:[(UITableView *)self.view indexPathForCell:(UITableViewCell *)sender].row];
    
    ExploreViewController *vc = (ExploreViewController *)segue.destinationViewController;
    vc.nickname = [u.nickname substringFromIndex:1];
    
}

#pragma mark - My methods

-(void)refresh {
    [self startModeLoadingWithText:NSLocalizedString(@"Loading", nil)];
    
    //Send request
    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
    NSString *session = [Utility encryptString:[Utility getSession]];
    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
    NSString *user_list_type = [Utility encryptString:[NSString stringWithFormat:@"%d",_listType]];
    NSString *myId = [Utility encryptString:(_listType == kListTypeLike) ? _post_id : _user_id];
    
    NSString *str = [URL_SERVER stringByAppendingString:@"get_users.php"];
    
    //Start parser thread
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setPostValue:device forKey:@"device"];
    [request setPostValue:session forKey:@"session"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
    [request setPostValue:user_list_type forKey:@"user_list_type"];
    [request setPostValue:myId forKey:(_listType == kListTypeLike) ? @"post_id" : @"user_id"];
    
    [request setDelegate:self];
    [request startAsynchronous];
}



- (void)requestFinished:(ASIHTTPRequest *)request
{
    //Only if controller isn't presented with curl
    [self stopModeLoading];
    [self.refreshControl endRefreshing];
    
    
    if (request.responseStatusCode == 200) {
        NSString *responseString = [request responseString];
        NSDictionary *responseDict = [responseString JSONValue];
        
        NSString *logged = [responseDict valueForKey:@"logged"];
        
        if([logged isEqualToString:@"1"]) {
            
            //Session valid
            NSString *response = [responseDict valueForKey:@"response"];
            
            
            if([response isEqualToString:@"-1"]) {
                
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errore del server" message:@"C'è stato un errore nella connessione al database! Riprova più tardi, grazie." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else if([response isEqualToString:@"1"]) {
                
                //GOOD Response
                [_arrUsers removeAllObjects];
                
                NSArray *users = (NSArray *)[responseDict valueForKey:@"users"];
                if([users count] > 0) {
                    for(NSDictionary *u in users) {
                        User *user = [[User alloc] initWithEncryptedDictonary:u];
                        [_arrUsers addObject:user];
                        [user release];
                    }
                }
                
                [self.tableView reloadData];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errore del server" message:@"C'è stato un errore nella connessione al database, riprova più tardi, grazie." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        } else if([logged isEqualToString:@"0"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[NSString stringWithFormat:@"La sessione di login non è valida, accedi nuovamente a %@!", APP_TITLE] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [[DataManager getInstance] logout];
            [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errore di connessione" message:@"C'è stato un errore durante la connessione al server. Assicurati di avere una connessione ad internet attiva oppure riprova più tardi, grazie." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
    }
    
    
}

- (void)dealloc
{
    [super dealloc];
}

@end
