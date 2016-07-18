//
//  PostViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 10/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#define IS_TABLE_HASHTAG (tableView.tag == 2)
#define POST_HAVE_IMAGE (_post.strImage && ![_post.strImage isEqualToString:@""])
#define POST_HAVE_MEDIA ([_post.mediaLink length] > 0)

#define TAG_BUTTON_LIKE 17
#define TAG_BUTTON_COMMENT 18
#define TAG_BUTTON_INFO 19
#define TAG_BUTTON_DELETE 90
#define TAG_BUTTON_REPLY 89

#define TAG_DESCR 14

#define TITLE_CELL_HEIGHT 66.0
#define BOTTOM_CELL_HEIGHT 35.0

#define TOP_COMMENT_CELL_OFFSET 30.0 //Offset from label and top
#define BOTTOM_COMMENT_CELL_OFFSET 30.0

#define BUTTON_INFO_HEIGHT 20.0


#define DESCR_WIDTH 304.0
#define DESCR_WIDTH_COMMENT 255.0

#import "PostViewController.h"
#import "Comment.h"
#import "ExploreViewController.h"
#import "WebViewController.h"
#import "ListPersonViewController.h"
#import "Followed.h"
#import "EmbeddedCode.h"
#import <CoreText/CoreText.h>


@interface PostViewController () {
    NSString *my_id;
    
    NSMutableArray *arrComments;
    NSIndexPath *selIndex;
    UITableViewController *tableViewController;
    
    //Searching
    NSMutableArray *arrSearch;
    NSString *oldSearchedString;
    
    //Actual type tag suggest
    BOOL isTypeHashtag; //If isn't hashtag, it's @
    
    NSMutableArray *arrRequest;
}
@end

@implementation PostViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrRequest = [[NSMutableArray alloc] initWithCapacity:0];
    
    /***Localized string nib***/
    [self.navigationItem setTitle:NSLocalizedString(@"titleComments", nil)];
    /********/
    
    
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
    
    [_tableList registerNib:[UINib nibWithNibName:@"PostTitleCellId" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:POST_TITLE_CELL_ID];
    [_tableList registerNib:[UINib nibWithNibName:@"PostCellId" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:POST_CELL_ID];
    [_tableList registerNib:[UINib nibWithNibName:@"PostImageCellId" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:POST_IMAGE_CELL_ID];
    [_tableList registerNib:[UINib nibWithNibName:@"PostWebViewCellId" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:POST_WEBVIEW_CELL_ID];

    my_id = [Utility getUserId];
    
    
    arrSearch = [[NSMutableArray alloc] initWithArray:[Utility getTags]];
    isTypeHashtag = YES;
    oldSearchedString = @"";
    
    //Set title and background of send button
	[_chatInput.sendButton setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
    
    UIImage *buttonImage = [[UIImage imageNamed:@"myBlueB.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [_chatInput.sendButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    _chatInput.backgroundColor = [UIColor whiteColor];

    _chatInput.textView.backgroundColor = [UIColor whiteColor];
    [_chatInput.sendButton setEnabled:NO];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    
    
    arrComments = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self startModeLoadingWithText:NSLocalizedString(@"Loading", nil)];
    
    [self refreshFromCommentId:@"-1"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - TableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (IS_TABLE_HASHTAG) return 1;
    if(!_post) return 0;
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (IS_TABLE_HASHTAG) return [arrSearch count]; //Dynamic
    if (section == 0) return 2;
    return [arrComments count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) return @"";
    int tot_comments = [arrComments count];
    return [NSString stringWithFormat:@"%d %@",tot_comments, tot_comments == 1 ? NSLocalizedString(@"comment", nil) : NSLocalizedString(@"comments", nil)];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    if (IS_TABLE_HASHTAG) {

        if(isTypeHashtag) {
            CellIdentifier = @"SearchCellId";
            
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
        
        return cell;
        
    }
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            CellIdentifier = POST_TITLE_CELL_ID;
            cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            RoundCornerImageView *imgProfile = (RoundCornerImageView *)[cell viewWithTag:10];
            [imgProfile setCircleMask];

            UILabel *lblTitle = (UILabel *)[cell viewWithTag:11];
            UILabel *lblAuthor = (UILabel *)[cell viewWithTag:12];
            UILabel *lblTime = (UILabel *)[cell viewWithTag:13];
            
            UIButton *btDelete = (UIButton *)[cell viewWithTag:TAG_BUTTON_DELETE];
            [btDelete setHidden:YES];
            
            [imgProfile setImage:_post.imgProfile];
            [lblTitle setText:_post.title];
            [lblAuthor setText:[[_post.name stringByAppendingString:@" "] stringByAppendingString:_post.surname]];
            
            [lblTime setText:[DateManipulator differenceFeedbackFromDate:_post.timestamp andDate:[NSDate date]]];
            
        } else {
            CellIdentifier = POST_CELL_ID;
            
            if (POST_HAVE_IMAGE) {
                CellIdentifier = POST_IMAGE_CELL_ID;
            } else if(POST_HAVE_MEDIA) {
                CellIdentifier = POST_WEBVIEW_CELL_ID;
            }
            
            cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

            /*******ASYNC DOWNLOAD IMAGE******/
            
            if(POST_HAVE_IMAGE) {
                if(!_post.image) {
                    //Provvisory image
                    UIImageView *imageView = (UIImageView *)[cell viewWithTag:15];
                    [imageView setImage:[UIImage imageNamed:@"no_image.png"]];
                    
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                    dispatch_async(queue, ^(void) {
                        
                        _post.image = [Utility getCachedImageFromPath:[URL_SERVER stringByAppendingString:PATH_IMAGES_POSTS] withName:_post.strImage];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (_post.image) {
                                UITableViewCell *myCell = [tableView cellForRowAtIndexPath:indexPath];
                                UIImageView *imageView = (UIImageView *)[myCell viewWithTag:15];
                                [imageView setImage:_post.image];
                            }
                        });
                        
                    });
                } else {
                    UIImageView *imageView = (UIImageView *)[cell viewWithTag:15];
                    [imageView setImage:_post.image];
                }
            } else if(POST_HAVE_MEDIA) {
                UIWebView *videoView = (UIWebView *)[cell viewWithTag:15];
                [[videoView scrollView] setBounces: NO]; // message notation
                NSString *html = [NSString stringWithFormat:EMBEDDED_CODE_YOUTUBE, _post.mediaLink, videoView.frame.size.width, videoView.frame.size.height];
                [videoView loadHTMLString:html baseURL:nil];
            }
            /*********************************/

            STTweetLabel *lblDescr = (STTweetLabel *)[cell viewWithTag:TAG_DESCR];
            
            UIView *witheBackground = (UIView *)[cell viewWithTag:16];
            
            /**Info string**/
            UIButton *btInfo = (UIButton *)[cell viewWithTag:19];
            
            NSString *strInfo = [self getInfoStringForPost:_post];
            
            [btInfo setTitle:strInfo forState:UIControlStateNormal];
            [btInfo addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
            [btInfo setEnabled:(_post.tot_likes > 0)];
            
            CGSize textSize = [strInfo sizeWithFont:[UIFont systemFontOfSize:11.0f] constrainedToSize:CGSizeMake(300, 20) lineBreakMode: NSLineBreakByWordWrapping];
            CGRect rectInfo = btInfo.frame;
            rectInfo.size.width = textSize.width+5.0;
            [btInfo setFrame:rectInfo];
            /******/
            
            NSString *descr = _post.descr;
            
            [lblDescr setText:descr];
            [lblDescr setTextColor:[UIColor colorWithWhite:0.25 alpha:1.0]];
            [lblDescr setFont:[UIFont systemFontOfSize:13.0]];
            [lblDescr setFrame:CGRectMake(lblDescr.frame.origin.x, lblDescr.frame.origin.y, DESCR_WIDTH, _post.textHeight+7.0)];
            
            //Check if must be posted the string with likes and comments info
            int offset = (_post.tot_comments > 0 || _post.tot_likes > 0) ? 15+BUTTON_INFO_HEIGHT : 15;
            if ((POST_HAVE_IMAGE || POST_HAVE_MEDIA) && [_post.descr length] == 0) {
                //Reduce space to image (just if there isn't text but only image)
                offset -= 15;
                
                if (offset > 0) {
                    offset += 4;
                }
            }
            
            [witheBackground setFrame:CGRectMake(witheBackground.frame.origin.x, witheBackground.frame.origin.y, witheBackground.frame.size.width , _post.textHeight+offset)];
            
            STLinkCallbackBlock callbackBlock = ^(STLinkActionType actionType, NSString *link) {
                
                
                // determine what the user clicked on
                switch (actionType) {
                        
                    // if the user clicked on an account (@_max_k)
                    case STLinkActionTypeAccount: {
                        //hashtag
                        ExploreViewController *ev = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
                        //Delete @
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
                        [self performSegueWithIdentifier:@"PostToWebView" sender:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]];
                        break;
                    }
                }

            };
            
            [lblDescr setCallbackBlock:callbackBlock];
            
            UIButton *btLike = (UIButton *)[cell viewWithTag:TAG_BUTTON_LIKE];
            [btLike addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
            [btLike setSelected:_post.like_me];
            
            UIButton *btComment = (UIButton *)[cell viewWithTag:TAG_BUTTON_COMMENT];
            [btComment setHidden:YES];
        }
    } else {
        Comment *comment = [arrComments objectAtIndex:indexPath.row];
        
        CellIdentifier = @"CommentCellId";
        cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        
        RoundCornerImageView *imgProfile = (RoundCornerImageView *)[cell viewWithTag:10];
        [imgProfile setCircleMask];
        
        UILabel *lblAuthor = (UILabel *)[cell viewWithTag:12];
        UILabel *lblTime = (UILabel *)[cell viewWithTag:13];
        STTweetLabel *lblDescr = (STTweetLabel *)[cell viewWithTag:TAG_DESCR];
        
        UIButton *btDelete = (UIButton *)[cell viewWithTag:TAG_BUTTON_DELETE];
        [btDelete addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
        [btDelete setHidden:!([comment.user_id isEqualToString:my_id] || [_post.user_id isEqualToString:my_id])];
        
        UIButton *btReply = (UIButton *)[cell viewWithTag:TAG_BUTTON_REPLY];
        [btReply addTarget:self action:@selector(touchMyButton:event:) forControlEvents:UIControlEventTouchUpInside];
        [btReply setHidden:[comment.user_id isEqualToString:my_id]];
        [btReply setTitle:[NSString stringWithFormat:@" %@",NSLocalizedString(@"btReply", nil)] forState:UIControlStateNormal];
        
        [imgProfile setImage:comment.imgProfile];
        [lblAuthor setText:[[comment.name stringByAppendingString:@" "] stringByAppendingString:comment.surname]];
        
        [lblTime setText:[DateManipulator differenceFeedbackFromDate:comment.timestamp andDate:[NSDate date]]];
        
        
        [lblDescr setText:comment.descr];
        [lblDescr setTextColor:[UIColor colorWithWhite:0.25 alpha:1.0]];
        [lblDescr setFont:[UIFont systemFontOfSize:13.0]];

        [lblDescr setFrame:CGRectMake(lblDescr.frame.origin.x, lblDescr.frame.origin.y, DESCR_WIDTH_COMMENT, comment.textHeight+7.0)];
                
        STLinkCallbackBlock callbackBlock = ^(STLinkActionType actionType, NSString *link) {
            
            
            // determine what the user clicked on
            switch (actionType) {
                    
                // if the user clicked on an account (@_max_k)
                case STLinkActionTypeAccount: {
                    //hashtag
                    ExploreViewController *ev = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
                    //Delete @
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
                    [self performSegueWithIdentifier:@"PostToWebView" sender:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]];
                    break;
                }
            }
            
        };
        
        [lblDescr setCallbackBlock:callbackBlock];
        
        //Set background color (only if the user is entered by clicking on a notification cell)
        if(_notifCommentId && [comment.comment_id isEqualToString:_notifCommentId]) {
            [cell.contentView setBackgroundColor:NOTIFICATION_NEW_COLOR];
        }
    }
    
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (IS_TABLE_HASHTAG) return 44.0;
    
    if (indexPath.section == 0) {
        
        //Title
        if (indexPath.row == 0) {
            return TITLE_CELL_HEIGHT;
        } else {
            NSString *descr = _post.descr;

            CGSize textSize;
            
            textSize = [descr sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(DESCR_WIDTH, 20000) lineBreakMode: NSLineBreakByWordWrapping];
            
            _post.textHeight = (descr.length > 0) ? textSize.height + 7.0 + 8.0 : 0.0;

            
            //Check if must be posted the string with likes and comments info
            int offset = (_post.tot_comments > 0 || _post.tot_likes > 0) ? 15+BUTTON_INFO_HEIGHT : 15;
            
            if (POST_HAVE_IMAGE || POST_HAVE_MEDIA) {
                offset += 320.0;
                if ([_post.descr length] == 0) {
                    //Reduce space to image (just if there isn't text but only image)
                    offset -= 15;
                    
                    if (offset > 0) {
                        offset += 4;
                    }
                }
            }
            
            return _post.textHeight + offset + BOTTOM_CELL_HEIGHT;
        }
    }
    
    Comment *comment = (Comment *)[arrComments objectAtIndex:indexPath.row];
    NSString *descr = comment.descr;
    
    CGSize textSize = [descr sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(DESCR_WIDTH_COMMENT, 20000) lineBreakMode: NSLineBreakByWordWrapping];
    
    comment.textHeight = textSize.height;
    
    return textSize.height+7.0 + BOTTOM_COMMENT_CELL_OFFSET + TOP_COMMENT_CELL_OFFSET;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(IS_TABLE_HASHTAG) {
        NSString *hashtag;
        
        if(isTypeHashtag)
            hashtag = [[arrSearch objectAtIndex:indexPath.row] lowercaseString];
        else
            hashtag = [[arrSearch objectAtIndex:indexPath.row] valueForKey:@"nickname"];
        
        //Get text
        UITextView *txtDescr = _chatInput.textView;
        NSString *currentString = [txtDescr.text substringToIndex:[txtDescr selectedRange].location];
        
        //Search the last word
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\S+\\z" options:0 error:nil];
        NSTextCheckingResult *found = [regex firstMatchInString:currentString options:0 range:NSMakeRange(0, currentString.length)];
        
        if (found.range.location != NSNotFound) {
            [txtDescr setText:[txtDescr.text stringByReplacingCharactersInRange:NSMakeRange(found.range.location, found.range.length) withString:[hashtag stringByAppendingString:@" "]]];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self getTagSuggests:NO];
        return;
    }
    
    
    if(indexPath.section == 0 && indexPath.row == 1) return;
        
    ExploreViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        
    if(indexPath.section == 0 && indexPath.row == 0) {
        vc.id_from = _post.user_id;
        vc.nickname = _post.nickname;
    } else if(indexPath.section == 1) {
        //It's a comment
        Comment *c = (Comment *)[arrComments objectAtIndex:indexPath.row];
        vc.id_from = c.user_id;
        vc.nickname = c.nickname;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    [_tableList deselectRowAtIndexPath:indexPath animated:YES];

}


#pragma mark - UITextFIeldDelegate



-(void)textViewDidChange:(UITextView *)textView {

    [_chatInput.sendButton setEnabled:!textView.text.length == 0];

    //Get text
    NSString *currentString = [textView.text substringToIndex:[textView selectedRange].location];
    //Search the last word
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\S+\\z" options:0 error:nil];
    NSTextCheckingResult *found = [regex firstMatchInString:currentString options:0 range:NSMakeRange(0, currentString.length)];
    NSString *lastWord = @"";
    
    if (found.range.location != NSNotFound) {
        lastWord = [currentString substringWithRange:found.range];
    }
    
    
    //Matching forbidden
    NSError *error;
    NSRegularExpression *regexForbiddenHashtag = [NSRegularExpression regularExpressionWithPattern:@"([^A-Z0-9a-z(é|ë|ê|è|à|â|ä|á|ù|ü|û|ú|ì|ï|î|í)_-]+)" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString *forbString = @"";
    if(lastWord.length > 0) {
        NSTextCheckingResult *f = [regexForbiddenHashtag firstMatchInString:lastWord options:0 range:NSMakeRange(1, [lastWord length]-1)];
        if (f.range.location != NSNotFound) {
            forbString = [lastWord substringWithRange:f.range];
        }
    }
    
    //Check
    if((lastWord.length == 0 || (![[lastWord substringToIndex:1] isEqualToString:@"#"] && ![[lastWord substringToIndex:1] isEqualToString:@"@"]) || forbString.length > 0) && !_tbHashtag.hidden) {
        [self getTagSuggests:NO];
    } else if (lastWord.length > 0 && ([[lastWord substringToIndex:1] isEqualToString:@"#"] || [[lastWord substringToIndex:1] isEqualToString:@"@"]) && forbString.length == 0) {
        
        [self filterContentForSearchText:[lastWord substringFromIndex:1] scope:([[lastWord substringToIndex:1] isEqualToString:@"#"]) ? 0 : 1];
        
        if([arrSearch count] > 0)
            [self getTagSuggests:YES];
        else if(!_tbHashtag.hidden)
            [self getTagSuggests:NO];
    }
    
}


- (void)filterContentForSearchText:(NSString*)str scope:(int)scopeIndex {
    isTypeHashtag = !scopeIndex;
    
    // for inCaseSensitive search
    if(isTypeHashtag) str = [str lowercaseString];
    if(!str) str = @"";
    
    NSArray *arrValue = [NSArray arrayWithArray:([str length] >= [oldSearchedString length] && [oldSearchedString length]>0) ? arrSearch : (scopeIndex == 0) ? [Utility getTags] : [Utility getFollowed]];
    
    NSString *query = @"";
    if(isTypeHashtag)
        query = [NSString stringWithFormat:@"SELF beginswith[cs] '#%@'",str];
    else
        query = [NSString stringWithFormat:@"nickname beginswith[cs] '@%@' OR name beginswith[cs] '%@' OR surname beginswith[cs] '%@'",str, str, str];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query];
    
    [arrSearch removeAllObjects];
    
    if([str length] > 0)
        [arrSearch addObjectsFromArray:[arrValue filteredArrayUsingPredicate:predicate]];
    
    oldSearchedString = [str retain];
    
    [_tbHashtag reloadData];
}


- (void)getTagSuggests:(BOOL)flag {
    [_tbHashtag setHidden:!flag];
    
    UITextView *textView = _chatInput.textView;
    [textView becomeFirstResponder];
}



#pragma mark - Request delegate

//Login parser end
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [arrRequest removeObject:request];
    
    if (request.responseStatusCode == 200) {
        NSString *responseString = [request responseString];
        NSDictionary *responseDict = [responseString JSONValue];
        
        NSString *logged = [responseDict valueForKey:@"logged"];
        
        if([logged isEqualToString:@"1"]) {
            //Session valid
            NSString *response = [responseDict valueForKey:@"response"];
            
            /*Check if is a deleting request*/
            if([request.method isEqualToString:SERVICE_DELETE_COMMENT]) {
                //Post is already deleted
                if([response isEqualToString:@"1"]) {
                    //Elimino
                    [arrComments removeObjectAtIndex:selIndex.row];
                    [_tableList deleteRowsAtIndexPaths:[NSArray arrayWithObject:selIndex] withRowAnimation:UITableViewRowAnimationMiddle];
                    
                    if(_post.tot_comments != [arrComments count]) {
                        _post.tot_comments--;
                        [_tableList reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    
                    [self stopModeLoading];
                    return;

                }
                
            }
            /**********************/
            
            if([response isEqualToString:@"-1"]) {
                
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                
            } else if([response isEqualToString:@"1"]) {
                
                if([request.method isEqualToString:SERVICE_COMMENT]) {
                    //Refrsh the message
                    [_chatInput.textView setText:@""];
                    _chatInput.lblPlaceholder.hidden = NO;
                    [_chatInput fitText];
                    
                    [self refreshFromCommentId:((Comment *)[arrComments lastObject]).comment_id];
                    
                } else {
                    
                    BOOL is_partial_get = [[responseDict valueForKey:@"is_partial_get"] isEqualToString:@"1"];
                    NSArray *comments = [responseDict valueForKey:@"comments"];
                                        
                    if(!is_partial_get)
                        arrComments = [[NSMutableArray alloc] initWithCapacity:0];
                    else
                        _post.tot_comments += [comments count];
                        
                    int lastArrLength = [arrComments count];
                    NSMutableArray *arrIndexPath = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    for(NSDictionary *comment in comments) {
                        Comment *c = [[Comment alloc] initWithId:[Utility decryptString:[comment valueForKey:@"id"]]
                                                         post_id:[Utility decryptString:[comment valueForKey:@"post_id"]]
                                                           descr:[Utility decryptString:[comment valueForKey:@"descr"]]
                                                       timestamp:[Utility decryptString:[comment valueForKey:@"timestamp"]]
                                                         user_id:[Utility decryptString:[comment valueForKey:@"user_id"]]
                                                        nickname:[Utility decryptString:[comment valueForKey:@"nickname"]]
                                                            name:[Utility decryptString:[comment valueForKey:@"name"]]
                                                         surname:[Utility decryptString:[comment valueForKey:@"surname"]]
                                                      imgProfile:[comment valueForKey:@"img_profile"]];
                        
                        [arrComments addObject:c];
                        
                        [arrIndexPath addObject:[NSIndexPath indexPathForRow:lastArrLength++ inSection:1]];
                    }
                    
                    [comments release];
                    
                    
                    BOOL reloadAll = NO;
                    NSDictionary *post = [responseDict valueForKey:@"post"];
                    
                    if(post && !_post) {
                        _post = [[Post alloc] initWithId:[Utility decryptString:[post valueForKey:@"id"]]
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
                        reloadAll = YES;
                        
                    }
                    
                    if(reloadAll) {
                        
                        if([_post.title isEqualToString:@""]) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"errorAccessToDeletedPost", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                            [alert release];
                            [self stopModeLoading];
                            return;
                        }
                        
                        [_tableList reloadData];
                    } else {
                        
                        
                        [CATransaction begin];
                        [CATransaction setCompletionBlock:^{
                            // animation has finished
                            [arrIndexPath release];
                            //Scroll tableview when complete refresh
                            
                            [CATransaction begin];
                            [CATransaction setCompletionBlock:^{
                                if(_clickComment || _postedComment) {
                                    _postedComment = NO;
                                    [_tableList scrollToBottom];
                                }
                            }];
                            [_tableList beginUpdates];
                            
                            [_tableList reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationNone];
                            
                            [_tableList endUpdates];
                            
                            [CATransaction commit];
                        }];
                        [_tableList beginUpdates];
                        
                        [_tableList insertRowsAtIndexPaths:arrIndexPath withRowAnimation:YES];
                        
                        [_tableList endUpdates];
                        
                        
                        [CATransaction commit];
                    }

                }
                
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
        [alert show];
        [alert release];
        
    }
    
    //Update info
    if(_post.tot_comments != [arrComments count]) {
        [_tableList reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if(_clickComment) {
        _clickComment = NO;
        [_chatInput.textView becomeFirstResponder];
    }
    
    
    [self stopModeLoading];
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    if([self isLoading]) [self stopModeLoading];
    
    NSError *error = [request error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection error", nil) message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


-(void)refreshFromCommentId:(NSString *)comment_id {
    //Start request
    if(!comment_id) comment_id = @"0";
    
    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
    NSString *session = [Utility encryptString:[Utility getSession]];
    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
    NSString *post_id = [Utility encryptString:(_post) ? _post.post_id : [NSString stringWithFormat:@"%d",_downloadPostID]];
    NSString *download_post = [Utility encryptString:(_post) ? @"0" : @"1"];
    
    NSString *str = [URL_SERVER stringByAppendingString:@"get_comments.php"];
    
    //Start parser thread
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setPostValue:device forKey:@"device"];
    [request setPostValue:session forKey:@"session"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
    [request setPostValue:post_id forKey:@"post_id"];
    [request setPostValue:download_post forKey:@"download_post"];
    
    [request setPostValue:[Utility encryptString:comment_id] forKey:@"from_comment_id"];
    
    [request setDelegate:self];
    [arrRequest addObject:request];
    [request startAsynchronous];
}

#pragma mark - Touch

- (void)touchMyButton:(UIButton*)button event:(UIEvent*)event
{

    NSString *post_id = _post.post_id;
    
    switch (button.tag) {
        case TAG_BUTTON_LIKE: {
            //It's the like button
            //Set Button
            [button setSelected:!button.selected];
            
            (button.selected) ? _post.tot_likes++ : _post.tot_likes--;
            
            [_post setLike_me:button.selected];
            
            /**String info**/
            //Refresh post cell
            [_tableList reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
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
        case TAG_BUTTON_DELETE: {
            
            UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageConfirmDeleteComment", nil) cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil),nil];
            
            [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
                if (didCancel) {
                    return;
                } else {
                    [self startModeLoadingWithText:NSLocalizedString(@"Delete comment", nil)];
                    
                    //Get post
                    NSIndexPath* indexPath = [_tableList indexPathForRowAtPoint:
                                              [[[event touchesForView:button] anyObject]
                                               locationInView:_tableList]];
                    Comment *comment = (Comment *)[arrComments objectAtIndex:indexPath.row];
                    NSString *comment_id = comment.comment_id;
                    
                    //Save the indexPAth
                    selIndex = [indexPath retain];
                    
                    //Set Button
                    //Start parser thread
                    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
                    NSString *session = [Utility encryptString:[Utility getSession]];
                    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
                    NSString *method = [Utility encryptString:SERVICE_DELETE_COMMENT];
                    comment_id = [Utility encryptString:comment_id];
                    
                    NSString *str = [URL_SERVER stringByAppendingString:@"request.php"];
                    
                    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
                    [request setPostValue:device forKey:@"device"];
                    [request setPostValue:session forKey:@"session"];
                    [request setPostValue:method forKey:@"method"];
                    [request setPostValue:token forKey:@"token"];
                    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
                    [request setPostValue:comment_id forKey:@"comment_id"];
                    [request setMethod:SERVICE_DELETE_COMMENT];
                    [request setDelegate:self];
                    [arrRequest addObject:request];
                    [request startAsynchronous];
                }
            }];
            
            break;
        }
        case TAG_BUTTON_REPLY: {
            
            //Get post
            NSIndexPath* indexPath = [_tableList indexPathForRowAtPoint:
                                      [[[event touchesForView:button] anyObject]
                                       locationInView:_tableList]];
            Comment *comment = (Comment *)[arrComments objectAtIndex:indexPath.row];
            
            _chatInput.textView.text = [NSString stringWithFormat:@"@%@ ",comment.nickname];
            [_chatInput.textView becomeFirstResponder];
            [_chatInput.lblPlaceholder setText:@""];
            
            break;
        }
        case TAG_BUTTON_INFO: {
            [self performSegueWithIdentifier:@"PostToLikes" sender:button];
            break;
        }
        default:
            break;
    }
}


#pragma mark - THC


- (void) textViewDidBeginEditing:(UITextView*)textView {
    //Scroll tableview
    [_tableList scrollToBottom];
}

- (void) sendButtonPressed:(id)sender {
    [self.view endEditing:YES];
    [self send];
}

- (void) returnButtonPressed:(id)sender {
    [_chatInput.textView setText:[_chatInput.textView.text stringByAppendingString:@"\n"]];
}

-(void)send {
    
    _postedComment = YES;
    
    [self startModeLoadingWithText:NSLocalizedString(@"Sending", nil)];
    
    NSString *descr = [Utility encryptString:_chatInput.textView.text];
    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
    NSString *session = [Utility encryptString:[Utility getSession]];
    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
    NSString *method = [Utility encryptString:SERVICE_COMMENT];
    NSString *post_id = [Utility encryptString:_post.post_id];
    
    NSString *str = [URL_SERVER stringByAppendingString:@"post.php"];
    
    //Start parser thread
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setPostValue:device forKey:@"device"];
    [request setPostValue:session forKey:@"session"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
    [request setPostValue:method forKey:@"method"];
    [request setPostValue:post_id forKey:@"post_id"];
    [request setPostValue:descr forKey:@"descr"];
    [request setMethod:SERVICE_COMMENT];
    [request setDelegate:self];
    [arrRequest addObject:request];
    [request startAsynchronous];
}


//The event handling method
- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [self.view endEditing:YES];
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

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PostToLikes"]) {
        ((ListPersonViewController *)segue.destinationViewController).listType = kListTypeLike;
        ((ListPersonViewController *)segue.destinationViewController).post_id = _post.post_id;
    } else if ([segue.identifier isEqualToString:@"PostToWebView"]) {
        WebViewController *webView = (WebViewController *)segue.destinationViewController;
        [webView setUrlRequest:(NSURLRequest *)sender];
    }
    
}


-(void)viewWillDisappear:(BOOL)animated { [super viewWillDisappear:animated];
    for (ASIHTTPRequest *req in arrRequest) {
        [req clearDelegatesAndCancel];
        [req setDelegate:nil];
        [req setDidFailSelector:nil];
        [req setDidFinishSelector:nil];
    }
    
    [self stopModeLoading];
}

- (void)dealloc
{
    [_chatInput release];
    [_tableList release];
    [_scrollView release];
    [_tbHashtag release];
    [super dealloc];
}

@end
