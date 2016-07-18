//
//  NotificationViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 19/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "NotificationViewController.h"
#import "PostViewController.h"
#import "ExploreViewController.h"

@interface NotificationViewController () {
    
}
@end

@implementation NotificationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /***Localized string nib***/
    [self.navigationItem setTitle:NSLocalizedString(@"titleNotification", nil)];
    /********/
    
    _arrNotific = [DataManager getInstance].arrNotific;
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@""
                                      style:UIBarButtonItemStylePlain
                                     target:nil
                                     action:nil] autorelease];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{
                              UITextAttributeFont:NAVBAR_FONT,
                              UITextAttributeTextColor:NAVBAR_TITLE_COLOR,
                              }];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.tabBarItem setBadgeValue:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateLastRead];
    [self.tableView reloadData];
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
    return [_arrNotific count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotificationCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UILabel *lblDescr = (UILabel *)[cell viewWithTag:14];
    UILabel *lblTime = (UILabel *)[cell viewWithTag:13];
    RoundCornerImageView *imgProfile = (RoundCornerImageView *)[cell viewWithTag:10];
    [imgProfile setCircleMask];
    
    Notification *notific = [_arrNotific objectAtIndex:indexPath.row];
    
    [imgProfile setImage:notific.sender_image];
    [lblDescr setAttributedText:notific.attributedString];
    [lblTime setText:[DateManipulator differenceFeedbackFromDate:notific.timestamp andDate:[NSDate date]]];
    
    [cell.contentView setBackgroundColor:(notific.is_new) ? NOTIFICATION_NEW_COLOR : [UIColor clearColor]];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *segueIdentifier = @"";
    
    Notification *n = [_arrNotific objectAtIndex:indexPath.row];
    
    switch (n.type) {
        case kNotificationTypeFollowed:
            segueIdentifier = @"NotifToProfileView";
            break;
        default:
            segueIdentifier = @"NotifToPostView";
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:segueIdentifier sender:[tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - DataManger Delegate

-(void)requestFromDManDidFinish:(ASIHTTPRequest *)request {
    [self updateLastRead];

    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

-(void)requestFromDManFailed:(ASIHTTPRequest *)request {
    [self stopModeLoading];
    [self.refreshControl endRefreshing];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UITableViewCell *cell = (UITableViewCell *)sender;
    Notification *notif = (Notification *)[_arrNotific objectAtIndex:[(UITableView *)self.view indexPathForCell:cell].row];
    
    UIViewController *vc = nil;
    
    if ([segue.identifier isEqualToString:@"NotifToPostView"]) {
        vc = (PostViewController *)segue.destinationViewController;
        ((PostViewController *)vc).downloadPostID = [notif.post_id intValue];
        
        if(notif.type == kNotificationTypeTaggedComment || notif.type == kNotificationTypeComment) {
            ((PostViewController *)vc).notifCommentId = notif.comment_id;
        }
    } else if([segue.identifier isEqualToString:@"NotifToProfileView"]) {
        vc = (ExploreViewController *)segue.destinationViewController;
        ((ExploreViewController *)vc).nickname = notif.sender_nickname;
    }
    
}

#pragma mark - My methods

-(void)updateLastRead {
    //Last readed notification
    NSMutableArray *notifications = [Utility getNotifications];
    NSString *last_read_notific = [NSString stringWithFormat:@"%d",[[notifications valueForKeyPath:@"@max.id.intValue"] intValue]];

    //Set last read notification
    [Utility setDefaultValue:last_read_notific forKey:NOTIFICATION_LAST_READ];
}

-(void)refresh {
    DataManager *dman = [DataManager getInstance];
    dman.delegate = self;
    [dman getNotifications];
}

-(void)dealloc {
    [_arrNotific release];
    [super dealloc];
}


@end
