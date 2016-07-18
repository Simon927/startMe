//
//  HomeViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 31/12/12.
//  Copyright (c) 2012 Matteo Gobbi. All rights reserved.
//

#define IS_SEARCHING (tableView == self.searchDisplayController.searchResultsTableView)
#define TYPE_POST_PROFILE ([_id_from intValue] > 0 || _nickname)
#define POST_HAVE_IMAGE (post.strImage && ![post.strImage isEqualToString:@""])
#define POST_HAVE_MEDIA ([post.mediaLink length] > 0)

#define SEARCHING_HASHATAG ([self.searchDisplayController.searchBar selectedScopeButtonIndex] == 0)
#define SEARCHING_PERSON ([self.searchDisplayController.searchBar selectedScopeButtonIndex] == 1)

#define TAG_BUTTON_FOLLOWERS 14
#define TAG_BUTTON_FOLLOWING 15
#define TAG_BUTTON_LIKE 17
#define TAG_BUTTON_COMMENT 18
#define TAG_BUTTON_INFO 19
#define TAG_BUTTON_FOLLOW 20
#define TAG_BUTTON_EMAIL 21
#define TAG_BUTTON_EDIT 22
#define TAG_BUTTON_IMAGE 23
#define TAG_BUTTON_SETTINGS 27
#define TAG_BUTTON_DELETE 90

#define TAG_DESCR 14 //Different cell rispect to the first one

#define PROFILE_CELL_HEIGHT 182.0
#define TITLE_CELL_HEIGHT 66.0
#define BOTTOM_CELL_HEIGHT 35.0
#define BUTTON_INFO_HEIGHT 20.0

#define DESCR_WIDTH 304.0

#import "ExploreViewController.h"
#import "Post.h"
#import "PostViewController.h"
#import "WebViewController.h"
#import "Followed.h"
#import "ChooseProfileImageViewController.h"
#import "ListPersonViewController.h"
#import "JoinViewController.h"
#import "EmbeddedCode.h"
#import <CoreText/CoreText.h>

@interface ExploreViewController () {
    NSString *my_id;
    
    NSMutableArray *arrPosts;
    NSIndexPath *selIndex;
    BOOL clickComment;
    BOOL myRefresh;
    BOOL bottomRefresh;
    
    //Searching
    NSMutableArray *arrSearch;
    NSString *oldSearchedString;
    BOOL onlineSeraching;
    
    //For profile
    BOOL is_me;
    int offsetCellPost;
    
    NSMutableArray *arrRequest;
}
@end

@implementation ExploreViewController

@synthesize hashtag, userInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrRequest = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@""
                                      style:UIBarButtonItemStylePlain
                                     target:nil
                                     action:nil] autorelease];
    
    [_tableList registerNib:[UINib nibWithNibName:@"PostTitleCellId" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:POST_TITLE_CELL_ID];
    [_tableList registerNib:[UINib nibWithNibName:@"PostCellId" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:POST_CELL_ID];
    [_tableList registerNib:[UINib nibWithNibName:@"PostImageCellId" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:POST_IMAGE_CELL_ID];
    [_tableList registerNib:[UINib nibWithNibName:@"PostWebViewCellId" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:POST_WEBVIEW_CELL_ID];
    
    
    offsetCellPost = 0;
    onlineSeraching = NO;

    
    //Pick up my id
    my_id = [Utility getUserId];
    
    [self startModeLoadingWithText:NSLocalizedString(@"Loading", nil)];
    
    if(hashtag) {
        _id_from = TYPE_POSTS_HASHTAG;
        self.title = hashtag;
        [self.navigationItem.backBarButtonItem setTitle:hashtag];
        
    } else if (TYPE_POST_PROFILE) {
        
        is_me = ([_id_from isEqualToString:my_id] || [_nickname isEqualToString:[Utility getNickname]]);
        
        [self.navigationItem.backBarButtonItem setTitle:[@"@" stringByAppendingString:_nickname]];

        [self.navigationItem setTitle:[NSString stringWithFormat:@"@%@",_nickname]];
        
        offsetCellPost = 1;
        
    } else if(self.tabBarController.selectedIndex == INDEX_OF_PROFILE) {
        //I'm in my profile
        is_me = YES;
        offsetCellPost = 1;
        _nickname = [Utility getNickname];
        
        /***Localized string nib***/
        [self.navigationItem setTitle:NSLocalizedString(@"titleProfile", nil)];
        UIBarButtonItem *btLogout = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"btLogout", nil) style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
        [self.navigationItem setRightBarButtonItem:btLogout];
        /********/
        
    } else {
        _id_from = (self.tabBarController.selectedIndex == 0) ? TYPE_POSTS_ALL : TYPE_POSTS_FOLLOWED;
        
        /***Localized string nib***/
        [self.navigationItem setTitle:([_id_from isEqualToString:TYPE_POSTS_ALL]) ? APP_TITLE : NSLocalizedString(@"titleFollowing", nil)];
        /********/
        
        if ([_id_from isEqualToString:TYPE_POSTS_ALL]) {
            
            [self.searchDisplayController.searchBar setScopeButtonTitles:[NSArray arrayWithObjects:@"Hashtag", NSLocalizedString(@"Users", nil), nil]];
            arrPosts = [[NSMutableArray alloc] initWithCapacity:0];
            arrSearch = [[NSMutableArray alloc] initWithArray:[Utility getTags]];
        }
    }
    
    
    clickComment = NO;
    myRefresh = NO;
    oldSearchedString = @"";
    
    [self refreshFromScratch:YES];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    if(self.searchDisplayController.isActive) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [[UIApplication sharedApplication] setStatusBarStyle:APP_STATUS_BAR_STYLE];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if(self.searchDisplayController.isActive) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
    
    [super viewWillAppear:animated];
    
    //I'm in explore: type post all
    if([_id_from isEqualToString: TYPE_POSTS_ALL]) {
        [self.navigationController.navigationBar
         setTitleTextAttributes:@{
                                  UITextAttributeFont:[UIFont fontWithName:APP_TITLE_FONT size:24.0],
                                  UITextAttributeTextColor:NAVBAR_TITLE_COLOR,
                                  }];
        
    } else {
        [self.navigationController.navigationBar
         setTitleTextAttributes:@{
                                  UITextAttributeFont:NAVBAR_FONT,
                                  UITextAttributeTextColor:NAVBAR_TITLE_COLOR,
                                  }];
        
    }
}

#pragma mark - TableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(IS_SEARCHING) return 1;
    if(_nickname) return (![self isLoading] && userInfo) ? [arrPosts count]+1 : 0; //Return also cell for profile..only if it doesn't loading and user exists
    
    return [arrPosts count]; //Dynamic
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(IS_SEARCHING) return ([self.searchDisplayController.searchBar.text length]>0) ? [arrSearch count] : 0; //Dynamic
    if(section == 0 && _nickname) return 1;
    
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    if (IS_SEARCHING) {
        
        if(SEARCHING_HASHATAG) {
            CellIdentifier = @"SearchCellId";
            
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            [cell.textLabel setText:[arrSearch objectAtIndex:indexPath.row]];
        } else {
            NSDictionary *dict = [arrSearch objectAtIndex:indexPath.row];
            Followed *f = [[[Followed alloc] initWithDictonary:dict] autorelease];
            
            //User cell
            CellIdentifier = @"UserCellId";
            cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            RoundCornerImageView *imgProfileView = (RoundCornerImageView *)[cell viewWithTag:10];
            [imgProfileView setCircleMask];
            UILabel *name = (UILabel *)[cell viewWithTag:11];
            UILabel *nickname = (UILabel *)[cell viewWithTag:12];

            [name setText:[NSString stringWithFormat:@"%@ %@",f.name,f.surname]];
            [nickname setText:f.nickname];
            [imgProfileView setImage:f.imgProfile];
        }
        
    } else {
        
        //If i'm in the profile
        if(indexPath.section == 0) {
            if (TYPE_POST_PROFILE) {
                
                //Profile cell
                CellIdentifier = @"ProfileCellId";
                cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                
                RoundCornerImageView *imgProfileView = (RoundCornerImageView *)[cell viewWithTag:10];
                UILabel *name = (UILabel *)[cell viewWithTag:11];
                UILabel *nickname = (UILabel *)[cell viewWithTag:12];
                UILabel *count_p = (UILabel *)[cell viewWithTag:13];
                UIButton *btFwing = (UIButton *)[cell viewWithTag:TAG_BUTTON_FOLLOWING];
                UIButton *btFwers = (UIButton *)[cell viewWithTag:TAG_BUTTON_FOLLOWERS];
                
                UIButton *btFollow = (UIButton *)[cell viewWithTag:TAG_BUTTON_FOLLOW];
                UIButton *btEmail = (UIButton *)[cell viewWithTag:TAG_BUTTON_EMAIL];
                UIButton *btEdit = (UIButton *)[cell viewWithTag:TAG_BUTTON_EDIT];
                UIButton *btSettings = (UIButton *)[cell viewWithTag:TAG_BUTTON_SETTINGS];
                UIButton *btChangeImage = (UIButton *)[cell viewWithTag:TAG_BUTTON_IMAGE];
                
                //UIView *line = (UIView *)[cell viewWithTag:99];
                
                [imgProfileView setImage:userInfo.imgProfile];
                [name setText:[NSString stringWithFormat:@"%@ %@",userInfo.name,userInfo.surname]];
                [nickname setText:[@"@" stringByAppendingString:_nickname]];
                [count_p setText:userInfo.count_p];
                [btFwers setTitle:userInfo.count_fwers forState:UIControlStateNormal];
                [btFwing setTitle:userInfo.count_fwing forState:UIControlStateNormal];
                
                if(is_me) {
                    [imgProfileView setImage:[Utility getProfileImage]];
                }
                
                [btFollow setHidden:is_me];
                [btEmail setHidden:is_me];
                [btEdit setHidden:!is_me];
                [btSettings setHidden:!is_me];
                [btChangeImage setHidden:!is_me];
                //[line setHidden:is_me];
                
                [btFwers setEnabled:[userInfo.count_fwers intValue] > 0];
                [btFwing setEnabled:[userInfo.count_fwing intValue] > 0];
                
                //Button's targets
                [btFollow addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
                [btFwers addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
                [btFwing addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
                [btEmail addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
                [btSettings addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
                [btChangeImage addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
                
                [btFollow setSelected:userInfo.is_followed];
                
                /***Localized string nib***/
                [btFollow setTitle:NSLocalizedString(@"btFollow", nil) forState:UIControlStateNormal];
                [btFollow setTitle:NSLocalizedString(@"btUnfollow", nil) forState:UIControlStateSelected];
                [btEdit setTitle:NSLocalizedString(@"btEdit", nil) forState:UIControlStateNormal];
                [((UILabel*)[cell viewWithTag:24]) setText:NSLocalizedString(@"lblPost", nil)];
                [((UILabel*)[cell viewWithTag:25]) setText:NSLocalizedString(@"lblFollowers", nil)];
                [((UILabel*)[cell viewWithTag:26]) setText:NSLocalizedString(@"lblFollowing", nil)];
                /********/
                return cell;
            }
        }
        
        Post *post = [arrPosts objectAtIndex:indexPath.section-offsetCellPost];
        
        if(indexPath.row == 0) {
            CellIdentifier = POST_TITLE_CELL_ID;
            cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            RoundCornerImageView *imgProfile = (RoundCornerImageView *)[cell viewWithTag:10];
            [imgProfile setCircleMask];
            
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:11];
            UILabel *lblAuthor = (UILabel *)[cell viewWithTag:12];
            UILabel *lblTime = (UILabel *)[cell viewWithTag:13];
            
            UIButton *btDelete = (UIButton *)[cell viewWithTag:TAG_BUTTON_DELETE];
            [btDelete addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
            
            //If i'm in my profile (is_me), show selete button on all posts
            [btDelete setHidden:!(is_me || [post.user_id isEqualToString:my_id])];
            
            [imgProfile setImage:post.imgProfile];
            [lblTitle setText:post.title];
            [lblAuthor setText:[[post.name stringByAppendingString:@" "] stringByAppendingString:post.surname]];
            
            [lblTime setText:[DateManipulator differenceFeedbackFromDate:post.timestamp andDate:[NSDate date]]];

        } else {
            CellIdentifier = POST_CELL_ID;
            
            if (POST_HAVE_IMAGE) { //|| POST_HAVE_MEDIA) {
                CellIdentifier = POST_IMAGE_CELL_ID;
            } else if(POST_HAVE_MEDIA) {
                CellIdentifier = POST_WEBVIEW_CELL_ID;
            }
            
            cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            

            /*******ASYNC DOWNLOAD IMAGE******/
            
            if(POST_HAVE_IMAGE) { //|| POST_HAVE_MEDIA) {
                if(!post.image) {
                    //Provvisory image
                    UIImageView *imageView = (UIImageView *)[cell viewWithTag:15];
                    [imageView setImage:[UIImage imageNamed:@"no_image.png"]];
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                    dispatch_async(queue, ^(void) {
                        
                        /*
                        if(POST_HAVE_MEDIA) {
                            //Just youtube now
                            NSString *url = [[@"http://img.youtube.com/vi/" stringByAppendingString:[Utility getYoutubeVideoID:post.mediaLink]] stringByAppendingString:@"/"];
                            
                            post.image = [Utility getCachedImageFromPath:url withName:@"0.jpg"];
                        } else*/
                            post.image = [Utility getCachedImageFromPath:[URL_SERVER stringByAppendingString:PATH_IMAGES_POSTS] withName:post.strImage];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (post.image) {
                                UITableViewCell *myCell = [tableView cellForRowAtIndexPath:indexPath];
                                UIImageView *imageView = (UIImageView *)[myCell viewWithTag:15];
                                [imageView setImage:post.image];
                            }
                        });
                        
                    });
                } else {
                    UIImageView *imageView = (UIImageView *)[cell viewWithTag:15];
                    [imageView setImage:post.image];
                }
            } else if(POST_HAVE_MEDIA) {
                UIWebView *videoView = (UIWebView *)[cell viewWithTag:15];
                [[videoView scrollView] setBounces: NO]; // message notation
                //videoView.delegate= self;
                NSString *html = [NSString stringWithFormat:EMBEDDED_CODE_YOUTUBE, post.mediaLink, videoView.frame.size.width, videoView.frame.size.height];
                [videoView loadHTMLString:html baseURL:nil];
            }
            

            /*********************************/
            
            STTweetLabel *lblDescr = (STTweetLabel *)[cell viewWithTag:TAG_DESCR];
            
            UIView *witheBackground = (UIView *)[cell viewWithTag:16];
            
            /**String info**/
            
            UIButton *btInfo = (UIButton *)[cell viewWithTag:19];
            
            NSString *strInfo = [self getInfoStringForPost:post];
            
            [btInfo setTitle:strInfo forState:UIControlStateNormal];
            [btInfo addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
            [btInfo setEnabled:(post.tot_likes > 0)];
            
            CGSize textSize = [strInfo sizeWithFont:[UIFont systemFontOfSize:11.0f] constrainedToSize:CGSizeMake(300, 20) lineBreakMode: NSLineBreakByWordWrapping];
            CGRect rectInfo = btInfo.frame;
            rectInfo.size.width = textSize.width+5.0;
            [btInfo setFrame:rectInfo];
            /******/
            
            NSString *descr = post.descr;
            
            //Cut the text
            if(POST_HAVE_IMAGE || POST_HAVE_MEDIA) {
                if(descr.length > POST_MAX_LENGHT_DESCR_IN_LIST_WITH_IMAGE)
                    descr = [[descr substringToIndex:POST_MAX_LENGHT_DESCR_IN_LIST_WITH_IMAGE-3] stringByAppendingString:@"..."];
            }
            
            [lblDescr setText:descr];
            [lblDescr setTextColor:[UIColor colorWithWhite:0.25 alpha:1.0]];
            [lblDescr setFont:[UIFont systemFontOfSize:13.0]];
            [lblDescr setFrame:CGRectMake(lblDescr.frame.origin.x, lblDescr.frame.origin.y, DESCR_WIDTH, post.textHeight+7.0)];
            
            //Check if must be posted the string with likes and comments info
            int offset = (post.tot_comments > 0 || post.tot_likes > 0) ? 15+BUTTON_INFO_HEIGHT : 15;
            if ((POST_HAVE_IMAGE || POST_HAVE_MEDIA) && [post.descr length] == 0) {
                //Reduce space to image (just if there isn't text but only image)
                offset -= 15;
                
                if (offset > 0) {
                    offset += 4;
                }
            }
            
            [witheBackground setFrame:CGRectMake(witheBackground.frame.origin.x, witheBackground.frame.origin.y, witheBackground.frame.size.width , post.textHeight+offset)];
            
            
            STLinkCallbackBlock callbackBlock = ^(STLinkActionType actionType, NSString *link) {
                
                
                // determine what the user clicked on
                switch (actionType) {
                        
                    // if the user clicked on an account (@_max_k)
                    case STLinkActionTypeAccount: {
                        //hashtag
                        ExploreViewController *ev = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
                        //Elimino la chiocciola per estrarre il link puro
                        ev.nickname = [link stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                        [self.navigationController pushViewController:ev animated:YES];
                        break;
                        
                        // if the user clicked on a hashtag (#thisisreallycool)
                    }
                    case STLinkActionTypeHashtag: {
                        //hashtag
                        ExploreViewController *ev = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowedViewController"];
                        ev.hashtag = [link lowercaseString];
                        [self.navigationController pushViewController:ev animated:YES];
                        break;
                    }
                    case STLinkActionTypeWebsite: {
                        //link
                        [self performSegueWithIdentifier:@"PostToWebView" sender:[NSURLRequest requestWithURL:[NSURL URLWithString:link ]]];
                        break;
                    }
                }
            };
            
            [lblDescr setCallbackBlock:callbackBlock];
            
            UIButton *btLike = (UIButton *)[cell viewWithTag:TAG_BUTTON_LIKE];
            [btLike addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
            [btLike setSelected:post.like_me];
            
            UIButton *btComment = (UIButton *)[cell viewWithTag:TAG_BUTTON_COMMENT];
            [btComment addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(IS_SEARCHING) return 44.0;
    
    //Profile
    if(indexPath.section == 0) {
        if (_nickname) return PROFILE_CELL_HEIGHT;
    }
    
    //Title
    if (indexPath.row == 0) {
        return TITLE_CELL_HEIGHT;
    }
    
    Post *post = [arrPosts objectAtIndex: indexPath.section-offsetCellPost];
    
    NSString *descr = post.descr;
    
    if(POST_HAVE_IMAGE || POST_HAVE_MEDIA) {
        if(descr.length > POST_MAX_LENGHT_DESCR_IN_LIST_WITH_IMAGE)
            descr = [[descr substringToIndex:POST_MAX_LENGHT_DESCR_IN_LIST_WITH_IMAGE-3] stringByAppendingString:@"..."];
    }
    
    CGSize textSize = [descr sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(DESCR_WIDTH, 20000) lineBreakMode: NSLineBreakByWordWrapping];
    
    //Check if must be posted the string with likes and comments info
    int offset = (post.tot_comments > 0 || post.tot_likes > 0) ? 15+BUTTON_INFO_HEIGHT : 15;
    
    if (POST_HAVE_IMAGE || POST_HAVE_MEDIA) {
        offset += 320.0;
        if ([post.descr length] == 0) {
            //Reduce space to image (just if there isn't text but only image)
            offset -= 15;
            
            if (offset > 0) {
                offset += 4;
            }
        }
    }
    
    post.textHeight = (descr.length > 0) ? textSize.height + 7.0 + 8.0 : 0.0;
    
    return post.textHeight + offset + BOTTOM_CELL_HEIGHT;
     
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(IS_SEARCHING) {
        
        if(SEARCHING_PERSON) {
            //hashtag
            ExploreViewController *ev = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            //Elimino la chiocciola per estrarre il link puro
            ev.nickname = [[[arrSearch objectAtIndex:indexPath.row] valueForKey:@"nickname"] substringFromIndex:1];
            [self.navigationController pushViewController:ev animated:YES];
            //[ev release];
        } else {
            ExploreViewController *ev = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowedViewController"];
            ev.hashtag = [[arrSearch objectAtIndex:indexPath.row] lowercaseString];
            [self.navigationController pushViewController:ev animated:YES];
            //[ev release];
        }
        
    } else {
        
        selIndex = indexPath;
        
        if(indexPath.row == 0) {
            if(TYPE_POST_PROFILE) return;
            
            Post *post = (Post *)[arrPosts objectAtIndex:indexPath.section-offsetCellPost];
            
            ExploreViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            
            vc.id_from = post.user_id;
            vc.nickname = post.nickname;
 
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if(indexPath.row == 1)
            [self performSegueWithIdentifier:@"ListToPostView" sender:self];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if(section == [arrPosts count]-1+offsetCellPost && bottomRefresh) {
        return _actLoad;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == [arrPosts count]-1+offsetCellPost && bottomRefresh) {
        return 60.0;
    }
    return 0;
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
    if ([segue.identifier isEqualToString:@"ListToPostView"]) {
        PostViewController *vc = (PostViewController *)segue.destinationViewController;
        vc.post = [arrPosts objectAtIndex:selIndex.section-offsetCellPost];
        
        vc.clickComment = clickComment;
        clickComment = NO;
    } else if ([segue.identifier isEqualToString:@"ProfileToChooseImageProfile"]) {
        ((ChooseProfileImageViewController *)segue.destinationViewController).modalityNick = NO;
        ((ChooseProfileImageViewController *)segue.destinationViewController).delegate = self;
    } else if ([segue.identifier isEqualToString:@"ProfileToFollowers"]) {
        ((ListPersonViewController *)segue.destinationViewController).listType = kListTypeFollowers;
        ((ListPersonViewController *)segue.destinationViewController).user_id = userInfo.user_id;
        ((ListPersonViewController *)segue.destinationViewController).nickname = userInfo.nickname;
    } else if ([segue.identifier isEqualToString:@"ProfileToFollowing"]) {
        ((ListPersonViewController *)segue.destinationViewController).listType = kListTypeFollowing;
        ((ListPersonViewController *)segue.destinationViewController).user_id = userInfo.user_id;
        ((ListPersonViewController *)segue.destinationViewController).nickname = userInfo.nickname;
    } else if ([segue.identifier isEqualToString:@"PostToLikes"]) {
        UIButton *bt = (UIButton *)sender;
        UITableViewCell *cell = (UITableViewCell *)bt.superview.superview.superview.superview;
        
        Post *post = [arrPosts objectAtIndex:[_tableList indexPathForCell:cell].section-offsetCellPost];
        ((ListPersonViewController *)segue.destinationViewController).listType = kListTypeLike;
        ((ListPersonViewController *)segue.destinationViewController).post_id = post.post_id;
    } else if ([segue.identifier isEqualToString:@"ProfileToEdit"]) {
        JoinViewController *editProfileView = (JoinViewController *)segue.destinationViewController;
        editProfileView.user = userInfo;
    } else if ([segue.identifier isEqualToString:@"PostToWebView"]) {
        WebViewController *webView = (WebViewController *)segue.destinationViewController;
        [webView setUrlRequest:(NSURLRequest *)sender];
    }
    
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self startModeLoadingWithText:@"Cerco.."];
    onlineSeraching = YES;
    
    [searchBar resignFirstResponder];
    
    //Send request
    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
    NSString *session = [Utility encryptString:[Utility getSession]];
    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
    NSString *user_list_type = [Utility encryptString:[NSString stringWithFormat:@"%d",kListTypeSearch]];
    NSString *search_value = [Utility encryptString:searchBar.text];
    
    //Creo la stringa di inserimento
    NSString *str = [URL_SERVER stringByAppendingString:@"get_users.php"];
    
    //Start parser thread
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setMethod:SERVICE_SEARCH_USERS];
    [request setPostValue:device forKey:@"device"];
    [request setPostValue:session forKey:@"session"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
    [request setPostValue:user_list_type forKey:@"user_list_type"];
    [request setPostValue:search_value forKey:@"search_value"];
    
    [request setDelegate:self];
    [arrRequest addObject:request];
    [request startAsynchronous];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if(searchBar.text.length == 0) {
        [arrSearch removeAllObjects];
        [arrSearch addObjectsFromArray:(SEARCHING_HASHATAG) ? [Utility getTags] : [Utility getFollowed]];
    }
    
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"UserCellId" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:USER_CELL_ID];
    
    // Hide navigation controller
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    return YES;
}


- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [[UIApplication sharedApplication] setStatusBarStyle:APP_STATUS_BAR_STYLE];
}

//Change scope
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [arrSearch removeAllObjects];
    
    [arrSearch addObjectsFromArray:(SEARCHING_HASHATAG) ? [Utility getTags] : [Utility getFollowed]];

	[self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];

	return YES;
}

- (void)filterContentForSearchText:(NSString*)str scope:(int)scopeIndex {

    if (SEARCHING_HASHATAG) str = [str lowercaseString];
    if(!str) str = @"";
    
    if(onlineSeraching) {
        oldSearchedString = @"";
    }
    
    NSArray *arrValue = [NSArray arrayWithArray:([str length] >= [oldSearchedString length] && !onlineSeraching) ? arrSearch : (SEARCHING_HASHATAG) ? [Utility getTags] : [Utility getFollowed]];

    NSString *query = @"";
    if(SEARCHING_HASHATAG)
        query = [NSString stringWithFormat:@"SELF beginswith[cs] '#%@'",str];
    else
        query = [NSString stringWithFormat:@"nickname beginswith[cs] '@%@' OR name beginswith[cs] '%@' OR surname beginswith[cs] '%@'",str, str, str];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
    
    [arrSearch removeAllObjects];
    [arrSearch addObjectsFromArray:[arrValue filteredArrayUsingPredicate:predicate]];

    oldSearchedString = [str retain];
    
    onlineSeraching = NO;
}



#pragma mark - Request delegate

//Login parser end
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [arrRequest removeObject:request];
    
    //Only if controller isn't presented with curl
    [self stopModeLoading];
    [self.refreshControl endRefreshing];

    if(bottomRefresh) {
        bottomRefresh = NO;
        [_tableList reloadSections:[NSIndexSet indexSetWithIndex:[arrPosts count]-1+offsetCellPost] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    myRefresh = NO;
    
    if (request.responseStatusCode == 200) {
        NSString *responseString = [request responseString];
        NSDictionary *responseDict = [responseString JSONValue];
        
        NSString *logged = [responseDict valueForKey:@"logged"];
        
        if([logged isEqualToString:@"1"]) {
            
            NSString *response = [responseDict valueForKey:@"response"];
            
            /*Check if it is a delete request*/
            if([request.method isEqualToString:SERVICE_DELETE_POST]) {
                //Il post è già stato eliminato dal server, devo solo aggiornare la tabella
                if([response isEqualToString:@"1"]) {
                    //Elimino
                    [arrPosts removeObjectAtIndex:selIndex.section-offsetCellPost];
                    [_tableList deleteSections:[NSIndexSet indexSetWithIndex:selIndex.section] withRowAnimation:UITableViewRowAnimationMiddle];
                    return;
                }
                
            }
            /**********************/
            
            //Check if there are new tags
            NSArray *new_tags = (NSArray *)[responseDict valueForKey:@"new_tags"];
            if([new_tags count] > 0) {
                NSMutableArray *tags = [NSMutableArray arrayWithArray:[Utility getTags]];
                for(NSString *t in new_tags) {
                    NSString *dt = [Utility decryptString:t];
                    [tags addObject:dt];
                }
                [Utility setDefaultObject:tags forKey:TAGS_DOWNLOADED];
                
                if(self.searchBar.selectedScopeButtonIndex == 0) {
                    [arrSearch removeAllObjects];
                    [arrSearch addObjectsFromArray:tags];
                }
            }
            //*****//
            
            //Save last refresh followed
            NSString *time = [responseDict valueForKey:@"followed_last_refresh"];
            if(time)
                [Utility setDefaultValue:time forKey:FOLLOWED_LAST_REFRESH];

            
            //Check if there are new (or updated) followed
            NSArray *new_followed = (NSArray *)[responseDict valueForKey:@"new_followed"];
            if([new_followed count] > 0) {
                
                NSMutableArray *followed = [NSMutableArray arrayWithArray:[Utility getFollowed]];
                
                for(NSDictionary *f in new_followed) {
                    Followed *new_f = [[Followed alloc] initWithEncryptedDictonary:f];

                    //Se esiste
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
                
                if(self.searchBar.selectedScopeButtonIndex == 1) {
                    [arrSearch removeAllObjects];
                    [arrSearch addObjectsFromArray:[Utility getFollowed]];
                }
            }
            //*****//
            
            
            if([response isEqualToString:@"-1"]) {
                
                //Request failed: reset button
                if ([request.method isEqualToString:SERVICE_FOLLOW]) {
                    UIButton *btFollow = (UIButton *)[[_tableList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:TAG_BUTTON_FOLLOW];
                    [btFollow setSelected:!btFollow.selected];
                    userInfo.is_followed = !btFollow.selected;
                }
                
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else if([response isEqualToString:@"1"]) {

                //GOOD Response
                
                //If war searching user
                if([request.method isEqualToString:SERVICE_SEARCH_USERS]) {
                    if(SEARCHING_PERSON) {
                        [arrSearch removeAllObjects];
                        
                        NSArray *users = (NSArray *)[responseDict valueForKey:@"users"];
                        if([users count] > 0) {
                            
                            for(NSDictionary *u in users) {
                                Followed *user = [[Followed alloc] initWithEncryptedDictonary:u];
                                [arrSearch addObject:[user toDictionary]];
                                [user release];
                            }

                        }
                        
                        [self.searchDisplayController.searchResultsTableView reloadData];
                    }
                    return;
                }
                
                
                if(TYPE_POST_PROFILE) {
                    //Save user info
                    if(userInfo) { userInfo = nil; [userInfo release]; }
                    userInfo = [[User alloc] initWithEncryptedDictonary:[responseDict valueForKey:@"user_profile"]];
                    
                    //Check if is the first refresh or not
                    if([_tableList numberOfSections] > 0) 
                        [_tableList reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    else
                        [_tableList insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                }
                
                BOOL is_partial_get = [[responseDict valueForKey:@"is_partial_get"] isEqualToString:@"1"];
                NSArray *posts = [responseDict valueForKey:@"posts"];
                
                if(!is_partial_get) {
                    arrPosts = [[NSMutableArray alloc] initWithCapacity:0];
                }
                
                int lastArrLength = [arrPosts count];
                
                for(NSDictionary *post in posts) {
                    Post *p = [[Post alloc] initWithId:[Utility decryptString:[post valueForKey:@"id"]]
                                                 title:[Utility decryptString:[post valueForKey:@"title"]]
                                                 descr:[Utility decryptString:[post valueForKey:@"descr"]]
                                                 image:[Utility decryptString:[post valueForKey:@"image"]]
                                             mediaLink:[Utility decryptString:[post valueForKey:@"media_link"]]
                                             timestamp:[Utility decryptString:[post valueForKey:@"timestamp"]]
                                             tot_likes:[[Utility decryptString:[post valueForKey:@"tot_likes"]] intValue]
                                               like_me:[Utility decryptString:[post valueForKey:@"l"]]
                                          tot_comments:[[Utility decryptString:[post valueForKey:@"tot_comments"]] intValue]
                                               user_id:[Utility decryptString:[post valueForKey:@"user_id"]]
                                               nickname:[Utility decryptString:[post valueForKey:@"nickname"]]
                                                  name:[Utility decryptString:[post valueForKey:@"name"]]
                                               surname:[Utility decryptString:[post valueForKey:@"surname"]]
                                            imgProfile:[Utility decryptString:[post valueForKey:@"img_profile"]]
                                                 email:[Utility decryptString:[post valueForKey:@"email"]]];
                    
                    [arrPosts addObject:p];
                    
                }
                

                //Reload post's cell to write the number of post
                if(lastArrLength == 0 && [_tableList numberOfSections] > 0+offsetCellPost)
                    [_tableList reloadData];
                else
                    [_tableList insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(lastArrLength+offsetCellPost,[posts count])] withRowAnimation:UITableViewRowAnimationFade];
                
                [posts release];
                
            } else if([response isEqualToString:@"UserNotEXISTS"]) {
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"errorNicknameNotExists", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            
        } else if([logged isEqualToString:@"OLDappVersion"]) {
            //Show alert
            UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageVersionOld", nil) cancelButtonTitle:NSLocalizedString(@"Not now", nil) otherButtonTitles:NSLocalizedString(@"Update", nil),nil];
            
            [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
                if (!didCancel) {
                    NSString *link = [responseDict valueForKey:@"update_link"];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
                }
                
                [[DataManager getInstance] logout];
                [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
                
                return;
            }];
            
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
    if([self isLoading]) [self stopModeLoading];
    [self.refreshControl endRefreshing];
    
    if(bottomRefresh) {
        bottomRefresh = NO;
        [_tableList reloadSections:[NSIndexSet indexSetWithIndex:[arrPosts count]-1+offsetCellPost] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    myRefresh = NO;
    
    NSError *error = [request error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    //Failed request: update botton
    if ([request.method isEqualToString:SERVICE_FOLLOW]) {
        UIButton *btFollow = (UIButton *)[[_tableList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:TAG_BUTTON_FOLLOW];
        [btFollow setSelected:!btFollow.selected];
    }
}


#pragma mark - my methods

-(void)refresh {
    [self refreshFromScratch:YES];
}

-(void)refreshFromScratch:(BOOL)flag {
    //Mutex
    if(myRefresh) return;
    myRefresh = YES;
    
    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
    NSString *session = [Utility encryptString:[Utility getSession]];
    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
    NSString *id_from = [Utility encryptString:_id_from];
    
    //Attach last tag received
    NSString *last_tag = [[Utility getTags] lastObject];
    last_tag = (last_tag) ? [Utility encryptString:last_tag] : [Utility encryptString:@""];
    //***//
    
    //Attach last followed received
    NSString *followed_last_refresh = [Utility getDefaultValueForKey:FOLLOWED_LAST_REFRESH];
    followed_last_refresh = (![followed_last_refresh isEqualToString:@""]) ? [Utility encryptString:followed_last_refresh] : [Utility encryptString:@"0"];
    //***//
    
    
    NSString *last_post_id = [Utility encryptString:@"0"];
    
    if(!flag) {
        last_post_id = (((Post *)[arrPosts lastObject]).post_id) ? ((Post *)[arrPosts lastObject]).post_id : @"0";
        last_post_id = [Utility encryptString:last_post_id];
    }
    
    
    NSString *str = [URL_SERVER stringByAppendingString:@"get_post.php"];
    
    //Start parser thread
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setPostValue:device forKey:@"device"];
    [request setPostValue:session forKey:@"session"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
    [request setPostValue:id_from forKey:@"id_from"];
    [request setPostValue:last_post_id forKey:@"last_post_id"];
    [request setPostValue:last_tag forKey:@"last_tag"];
    [request setPostValue:followed_last_refresh forKey:@"followed_last_refresh"];
    
    if([_id_from isEqualToString:TYPE_POSTS_HASHTAG])
        [request setPostValue:[Utility encryptString:hashtag] forKey:@"hashtag"];
    
    if(_nickname)
        [request setPostValue:[Utility encryptString:_nickname] forKey:@"nickname"];
    
    [request setDelegate:self];
    [arrRequest addObject:request];
    [request startAsynchronous];
    
    //Get also notifications
    [[DataManager getInstance] getNotifications];
}

#pragma mark - Touch

- (void)touchMyButton:(UIButton*)button event:(UIEvent*)event
{
    
    switch (button.tag) {
        case TAG_BUTTON_LIKE: {
            NSIndexPath* indexPath = [_tableList indexPathForRowAtPoint:
                                      [[[event touchesForView:button] anyObject]
                                       locationInView:_tableList]];
            Post *post = (Post *)[arrPosts objectAtIndex:indexPath.section-offsetCellPost];
            NSString *post_id = post.post_id;
            
            //It's the like button
            //Set Button
            [button setSelected:!button.selected];   
            (button.selected) ? post.tot_likes++ : post.tot_likes--;
            [post setLike_me:button.selected];
            //Ricarico la cella del post cosi da scrivere il numero esatto di commenti
            [_tableList reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            //Start parser thread
            NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
            NSString *session = [Utility encryptString:[Utility getSession]];
            NSString *token = [Utility encryptString:[Utility getDeviceToken]];
            NSString *value = [Utility encryptString:[NSString stringWithFormat:@"%d",button.selected]];
            
            //Post's ID
            post_id = [Utility encryptString:post_id];
            
            NSString *str = [URL_SERVER stringByAppendingString:@"like.php"];
            
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
            [request setPostValue:device forKey:@"device"];
            [request setPostValue:session forKey:@"session"];
            [request setPostValue:token forKey:@"token"];
            [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
            [request setPostValue:post_id forKey:@"post_id"];
            [request setPostValue:value forKey:@"value"];
            [request setDelegate:self];
            [arrRequest addObject:request];
            [request startAsynchronous];
            
            break;
        }
        case TAG_BUTTON_COMMENT: {
            NSIndexPath* indexPath = [_tableList indexPathForRowAtPoint:
                                      [[[event touchesForView:button] anyObject]
                                       locationInView:_tableList]];
            
            //It's the comment button
            clickComment = YES;
            [self tableView:_tableList didSelectRowAtIndexPath:indexPath];
            
            break;
        }
        case TAG_BUTTON_FOLLOW: {

            //It's the like button
            //Set Button
            [button setSelected:!button.selected];
            userInfo.is_followed = !button.selected;
            
            //Start parser thread
            NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
            NSString *session = [Utility encryptString:[Utility getSession]];
            NSString *token = [Utility encryptString:[Utility getDeviceToken]];
            NSString *followed_id = [Utility encryptString:userInfo.user_id];
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
            [arrRequest addObject:request];
            [request startAsynchronous];
            
            break;
        }
        case TAG_BUTTON_EMAIL: {
            
            if(![userInfo.email isEqualToString:@""]) {
                if ([MFMailComposeViewController canSendMail])
                {
                    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                    mailer.mailComposeDelegate = self;
                    [mailer setSubject:[NSString stringWithFormat:@"%@: email da %@", APP_TITLE, [Utility getNickname]]];
                    NSArray *toRecipients = [NSArray arrayWithObjects:userInfo.email, nil];
                    [mailer setToRecipients:toRecipients];;
                    [self.navigationController presentViewController:mailer animated:YES completion:nil];
                    [mailer release];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE
                                                                    message:NSLocalizedString(@"errorEmailInApp", nil)
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                    [alert release];
                }
                
                break;
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE
                                                                message:NSLocalizedString(@"messageNotUserEmail", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }
        case TAG_BUTTON_IMAGE: {
            [self performSegueWithIdentifier:@"ProfileToChooseImageProfile" sender:self];
            break;
        }
        case TAG_BUTTON_INFO: {
            [self performSegueWithIdentifier:@"PostToLikes" sender:button];
            break;
        }
        case TAG_BUTTON_DELETE: {
            
            //Get post
            NSIndexPath* indexPath = [_tableList indexPathForRowAtPoint:
                                      [[[event touchesForView:button] anyObject]
                                       locationInView:_tableList]];
            Post *post = (Post *)[arrPosts objectAtIndex:indexPath.section-offsetCellPost];
            
            NSString *message = ([post.user_id isEqualToString:my_id]) ? NSLocalizedString(@"messageConfirmDeletePost", nil) : NSLocalizedString(@"messageConfirmHidePost", nil);
            
            UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:APP_TITLE message:message cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil),nil];
            
            [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
                if (didCancel) {
                    return;
                } else {
                    [self startModeLoadingWithText:([post.user_id isEqualToString:my_id]) ? NSLocalizedString(@"Delete post", nil) : NSLocalizedString(@"Hidden post", nil)];
                    
                    
                    NSString *post_id = post.post_id;
                    
                    //Save indexPath
                    selIndex = [indexPath retain];
                    
                    //Set Button
                    //Start parser thread
                    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
                    NSString *session = [Utility encryptString:[Utility getSession]];
                    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
                    NSString *method = [Utility encryptString:SERVICE_DELETE_POST];
                    post_id = [Utility encryptString:post_id];
                    
                    NSString *str = [URL_SERVER stringByAppendingString:@"request.php"];
                    
                    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
                    [request setPostValue:device forKey:@"device"];
                    [request setPostValue:session forKey:@"session"];
                    [request setPostValue:token forKey:@"token"];
                    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
                    [request setPostValue:method forKey:@"method"];
                    [request setPostValue:post_id forKey:@"post_id"];
                    [request setMethod:SERVICE_DELETE_POST];
                    [request setDelegate:self];
                    [arrRequest addObject:request];
                    [request startAsynchronous];
                }
            }];
            
            break;
        }
        default:
            break;
    }

}


-(NSString *)getInfoStringForPost:(Post *)post {
    NSString *strInfo = @"";
    if(post.tot_likes > 0)
        strInfo = [NSString stringWithFormat:@"%d %@", post.tot_likes, post.tot_likes == 1 ? NSLocalizedString(@"like", nil) : NSLocalizedString(@"likes", nil)];
    
    if(post.tot_comments > 0) {
        if([strInfo length] > 0)
            strInfo = [strInfo stringByAppendingString:@", "];
        strInfo = [strInfo stringByAppendingFormat:@"%d %@", post.tot_comments, post.tot_comments == 1 ? NSLocalizedString(@"comment", nil) : NSLocalizedString(@"comments", nil)];
    }
    return strInfo;
}


- (void)logout {
    [[DataManager getInstance] logout];
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIScrollViewDelegate


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    
    if(bottomRefresh || myRefresh) return;
    
    
    //Determine if the scrollview is all scrolled
    if(((NSIndexPath*)[_tableList.indexPathsForVisibleRows lastObject]).section == [arrPosts count]-1+offsetCellPost) {
        
        
        bottomRefresh = YES;
        [_tableList reloadSections:[NSIndexSet indexSetWithIndex:[arrPosts count]-1+offsetCellPost] withRowAnimation:UITableViewRowAnimationNone];
        
        [self refreshFromScratch:NO];
    }
}

#pragma mark - Email Composer delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
            
        default: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Service error", nil)
                                                            message:NSLocalizedString(@"errorSendingEmail", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            [alert release];
            break;
        }
    }
    
    // Remove the mail view
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated { [super viewWillDisappear:animated];
    for (ASIHTTPRequest *req in arrRequest) {
        [req clearDelegatesAndCancel];
        [req setDelegate:nil];
        [req setDidFailSelector:nil];
        [req setDidFinishSelector:nil];
    }
    
    [self stopModeLoading];
    [self.refreshControl endRefreshing];
}

#pragma mark - WebViewDelegate

/*
-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self performSelector:@selector(stopRunLoop) withObject:nil afterDelay:.01];
}

-(void) stopRunLoop
{
    CFRunLoopRef runLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
    CFRunLoopStop(runLoop);
}
*/


- (void)dealloc {
    [userInfo release];
    [arrSearch release];
    
    [_searchBar release];
    [_tableList release];
    [_id_from release];
    [_actLoad release];
    [hashtag release];
    [_nickname release];
    [super dealloc];
}

@end
