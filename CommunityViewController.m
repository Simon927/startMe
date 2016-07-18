//
//  CommunityViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 31/07/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "CommunityViewController.h"
#import "ChooseProfileImageViewController.h"

@interface CommunityViewController ()

@end

@implementation CommunityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self addCenterButtonWithImage:[UIImage imageNamed:@"share2.png"] highlightImage:nil];
    
    DataManager *dman = [DataManager getInstance];
    [dman setCommunityViewController:self];
    [dman updateBadgeNotification];
    
    if([Utility userIsLogged]) [[DataManager getInstance] getNotifications];
    
    [((UINavigationController *)[self.viewControllers objectAtIndex:INDEX_OF_EXPLORE]).tabBarItem setTitle:NSLocalizedString(@"btTabBarExplore", nil)];
    [((UINavigationController *)[self.viewControllers objectAtIndex:INDEX_OF_FOLLOWING]).tabBarItem setTitle:NSLocalizedString(@"btTabBarFollowing", nil)];
    [((UINavigationController *)[self.viewControllers objectAtIndex:INDEX_OF_NOTIFICATIONS]).tabBarItem setTitle:NSLocalizedString(@"btTabBarNotification", nil)];
    [((UINavigationController *)[self.viewControllers objectAtIndex:INDEX_OF_PROFILE]).tabBarItem setTitle:NSLocalizedString(@"btTabBarProfile", nil)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if(_chooseImage) {
        [self performSegueWithIdentifier:@"CommunityToChooseImageProfile" sender:self];
        _chooseImage = NO;
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"CommunityToChooseImageProfile"]) {
        ((ChooseProfileImageViewController *)segue.destinationViewController).modalityNick = YES;
    }
    
}


-(void)centerButtonPressed {
    if([DataManager getInstance].isSendingPost) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageSendingPost", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    [super centerButtonPressed];
    
    [self performSegueWithIdentifier:@"CommunityToShare" sender:self];
}

@end
