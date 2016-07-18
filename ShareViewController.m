//
//  ShareViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 05/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#define IS_TABLE_HASHTAG (tableView.tag == 2)
#define TAG_PROFILE_IMAGE 10
#define TAG_TITLEFIELD 11
#define TAG_TEXTVIEW 12
#define TAG_LBL_COUNTER 13
#define TAG_IMAGE 14
#define TAG_BUTTON_IMAGE 15
#define TAG_BUTTON_DELETE_IMAGE 16

#import "ShareViewController.h"
#import "SSTextView.h"
#import "Followed.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ShareViewController () {
    UILabel *lblCounter;
    
    //Searching
    NSMutableArray *arrSearch;
    NSString *oldSearchedString;
    
    //Actual type tag suggest
    BOOL isTypeHashtag; //If isn't hashtag, it's @
    
    BOOL postHaveImage;
    
    NSString *mediaLink;
}

@end

@implementation ShareViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    /****SET COLOR OF THE NAVBAR****/
    [[self.view viewWithTag:99] setBackgroundColor:NAVBAR_BACKGROUND_COLOR];
    [[self.view viewWithTag:99] setAlpha:0.58];
    /************************/
    
    /***Localized string nib***/
    [navBar setTitle:NSLocalizedString(@"titleShare", nil)];
    [btDone setTitle:NSLocalizedString(@"btShare", nil)];
    /********/

    
    arrSearch = [[NSMutableArray alloc] initWithArray:[Utility getTags]];
    isTypeHashtag = YES;
    oldSearchedString = @"";
    
    postHaveImage = NO;
    mediaLink = nil;
    
    [lblCounter setText:[NSString stringWithFormat:@"%d",POST_DESCR_MAX_LENGHT]];
    
    float tbHashHeight = self.view.frame.size.height - 235.0 - 216.0 + 80.0;
    CGRect rect = tbHashtag.frame;
    rect.size.height = tbHashHeight;
    [tbHashtag setFrame:rect];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDelegate and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (IS_TABLE_HASHTAG) return 1;
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (IS_TABLE_HASHTAG) return [arrSearch count]; //Dynamic
    return 2;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier;
    CellIdentifier = (indexPath.row == 0) ? @"TitleCellId" : @"DescrCellId";
    
    if (IS_TABLE_HASHTAG) {
        UITableViewCell *cell;
        
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
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    switch ([indexPath row]) {
        case 0: {
            RoundCornerImageView *imgProfile = (RoundCornerImageView *)[cell viewWithTag:TAG_PROFILE_IMAGE];
            [imgProfile setCircleMask];
            
            UITextField *textField = (UITextField *)[cell viewWithTag:11];
            
            [textField setAttributedPlaceholder:[[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Title's post", nil) attributes:@{NSForegroundColorAttributeName: APP_PLACEHOLDER_TEXT_COLOR}] autorelease]];
            
            [imgProfile setImage:[Utility getProfileImage]];
            
            [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            
            [textField becomeFirstResponder];
            break;

        } case 1: {
            
            SSTextView *textView = (SSTextView *)[cell viewWithTag:TAG_TEXTVIEW];
            [textView setPlaceholder:NSLocalizedString(@"Details", nil) ];
            
            lblCounter = (UILabel *)[cell viewWithTag:TAG_LBL_COUNTER];
            [lblCounter setText:[NSString stringWithFormat:@"%d", POST_DESCR_MAX_LENGHT]];
            
            RoundCornerImageView *img = (RoundCornerImageView *)[cell viewWithTag:TAG_IMAGE];
            [img setBorderWidth:0.0];
            [img setCornerRadius:3.0];
            
            UIButton *btImage = (UIButton *)[cell viewWithTag:TAG_BUTTON_IMAGE];
            [btImage addTarget:self action:@selector(attachMedia) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *btDelImage = (UIButton *)[cell viewWithTag:TAG_BUTTON_DELETE_IMAGE];
            [btDelImage addTarget:self action:@selector(deleteImage) forControlEvents:UIControlEventTouchUpInside];
            
            break;
            
        } default:
            break;
    }

    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_TABLE_HASHTAG) return 44.0;
        
    switch ([indexPath row]) {
        case 0:
            return 66.0;
            break;
        case 1:
            return 110.0;
            break;
        default:
            break;
    }
    
    return 44.0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(IS_TABLE_HASHTAG) {
        NSString *hashtag;
        
        if(isTypeHashtag)
            hashtag = [[arrSearch objectAtIndex:indexPath.row] lowercaseString];
        else
            hashtag = [[arrSearch objectAtIndex:indexPath.row] valueForKey:@"nickname"];
        
        //Get text
        SSTextView *txtDescr = (SSTextView *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TAG_TEXTVIEW];
        NSString *currentString = [txtDescr.text substringToIndex:[txtDescr selectedRange].location];
                                   
        //Search the last word
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\S+\\z" options:0 error:nil];
        NSTextCheckingResult *found = [regex firstMatchInString:currentString options:0 range:NSMakeRange(0, currentString.length)];
        
        if (found.range.location != NSNotFound) {
            [txtDescr setText:[txtDescr.text stringByReplacingCharactersInRange:NSMakeRange(found.range.location, found.range.length) withString:[hashtag stringByAppendingString:@" "]]];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self getTagSuggests:NO];
    }
}

/******/

#pragma mark - UITextFIeldDelegate

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    // Determine the row number of the active UITextField in which "return" was just pressed.
    if (textField.tag == TAG_TITLEFIELD) {
        [(UITextView *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TAG_TEXTVIEW] becomeFirstResponder];
    }
    
    return YES ;
}

-(void)textFieldDidChange:(UITextField *)textField {
    if(textField.text.length > POST_TITLE_MAX_LENGHT) {
        [textField setText:[textField.text substringToIndex:POST_TITLE_MAX_LENGHT]];
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    
    if(textView.text.length > POST_DESCR_MAX_LENGHT) {
        [textView setText:[textView.text substringToIndex:POST_DESCR_MAX_LENGHT]];
    }
    
    
    [lblCounter setText:[NSString stringWithFormat:@"%d", POST_DESCR_MAX_LENGHT-textView.text.length]];
    
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
    if((lastWord.length == 0 || (![[lastWord substringToIndex:1] isEqualToString:@"#"] && ![[lastWord substringToIndex:1] isEqualToString:@"@"]) || forbString.length > 0) && !tbHashtag.hidden) {
        [self getTagSuggests:NO];
    } else if (lastWord.length > 0 && ([[lastWord substringToIndex:1] isEqualToString:@"#"] || [[lastWord substringToIndex:1] isEqualToString:@"@"]) && forbString.length == 0) {
        
        [self filterContentForSearchText:[lastWord substringFromIndex:1] scope:([[lastWord substringToIndex:1] isEqualToString:@"#"]) ? 0 : 1];
        
        if([arrSearch count] > 0)
            [self getTagSuggests:YES];
        else if(!tbHashtag.hidden)
            [self getTagSuggests:NO];
    }
}


- (void)getTagSuggests:(BOOL)flag {
    [tbHashtag setHidden:!flag];
    float y = (flag) ? 73 : 0;
    [tb setContentOffset:CGPointMake(0, y) animated:NO];
    
    SSTextView *textView = (SSTextView *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TAG_TEXTVIEW];
    [textView becomeFirstResponder];
}


-(IBAction)post:(id)sender {
    
    //Send logout online
    NSString *title = ((UITextField *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:TAG_TITLEFIELD]).text;
    NSString *descr = ((SSTextView *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TAG_TEXTVIEW]).text;
    UIImageView *imgView = (UIImageView *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TAG_IMAGE];
    
    if([title length] < POST_TITLE_MIN_LENGHT) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[NSString stringWithFormat:NSLocalizedString(@"INVALIDtitlePost", nil),POST_TITLE_MIN_LENGHT] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    } else if([descr length] < POST_DESCR_MIN_LENGHT) {
        
        if([descr length] > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[NSString stringWithFormat:NSLocalizedString(@"INVALIDdescrPost", nil),POST_DESCR_MIN_LENGHT] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        } else if(!postHaveImage && !mediaLink) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:[NSString stringWithFormat:NSLocalizedString(@"ERRORonlyTitlePost", nil),POST_DESCR_MIN_LENGHT] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
    }
    
    [self.view endEditing:YES];
    
    [self setModeLoading:YES withText:NSLocalizedString(@"Sending", nil)];
    
    title = [Utility encryptString:title];
    descr = [Utility encryptString:descr];
    NSString *link = [Utility encryptString:mediaLink];
    
    NSData *img_data = nil;
    if(postHaveImage) {
        UIImage *image = [Utility scaleImage:imgView.image toSize:CGSizeMake(320, 320) ];
        img_data = UIImageJPEGRepresentation(image, 1.0);
    }
    
    [[DataManager getInstance] postWithTitle:title descr:descr imageData:img_data mediaLink:link];
    
    //Optional: return to the explore view.
    [[DataManager getInstance].communityViewController setSelectedIndex:0];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


//Disable command and active mode loading
-(void)setModeLoading:(BOOL)active withText:(NSString *)text {
    [super setModeLoading:active withText:text];
    
    //Set extra controls (ex. Button item on navBar)
    btDone.enabled = !active;
}


#pragma mark - parser end

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
    
    [tbHashtag reloadData];
}

#pragma mark - my methods

- (void)attachMedia {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Choose attachment", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Image",nil), NSLocalizedString(@"Link Video",nil), nil];
    [sheet showInView:self.view];
}

- (void)deleteImage {
    postHaveImage = NO;
    mediaLink = nil;
    UIImageView *imgView = (UIImageView *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TAG_IMAGE];
    [imgView setImage:[UIImage imageNamed:@"add.png"]];
    
    UIButton *btDelImage = (UIButton *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TAG_BUTTON_DELETE_IMAGE];
    [btDelImage setHidden:YES];
}


-(void) imagePickerControllerDidCancel:(DLCImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerController:(DLCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:APP_STATUS_BAR_STYLE];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (info) {
        NSData *image_data = [info objectForKey:@"data"];
        
        postHaveImage = YES;
        mediaLink = nil;
        
        UIImageView *imgView = (UIImageView *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TAG_IMAGE];
        [imgView setImage:[UIImage imageWithData:image_data]];
        
        UIButton *btDelImage = (UIButton *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TAG_BUTTON_DELETE_IMAGE];
        [btDelImage setHidden:NO];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageDataToSavedPhotosAlbum:image_data metadata:nil completionBlock:nil];
    }
}

#pragma mark - alertView and actionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        NSLog(@"Cancel button index tapped");
    } else  {
        switch (buttonIndex) {
            case 0: {
                DLCImagePickerController *picker = [[DLCImagePickerController alloc] init];
                picker.delegate = self;
                [self presentViewController:picker animated:YES completion:nil];
                [picker release];
                break;
            }
            case 1: {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageInsertVideoLink", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@"OK",nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert show];
                break;
            }
            default:
                break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString* link = [[alertView textFieldAtIndex:0] text];
    if ([link length] <= 0 || buttonIndex == [alertView cancelButtonIndex]){
        return;
    } else {
        
        //Check link
        link = [link stringByReplacingOccurrencesOfString:@"watch?v=" withString:@"v/"];
        
        NSString *regex = @"(https?://)?(www.)?(youtu.be|(m.)?youtube.[a-z]{2,4})?(/|/embed/|/v/|/watch\\?v=|/watch\\?.+&v=)([\\w_-]{11})(&.+)?"; //old: @"http(s?)://(www.)?youtube.[a-z]{2,4}/v/[0-9a-zA-Z_]{3,}"
        
        if([Utility stringIsValid:link regex:regex]) {
            
            link = [@"https://www.youtube.com/v/" stringByAppendingString:[Utility getYoutubeVideoID:link]];
            postHaveImage = NO;
            mediaLink = [link retain];
            
            //Set image
            UIImageView *imgView = (UIImageView *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TAG_IMAGE];
            [imgView setImage:[UIImage imageNamed:@"video.png"]];
            
            //Show button delete
            UIButton *btDelImage = (UIButton *)[[tb cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] viewWithTag:TAG_BUTTON_DELETE_IMAGE];
            [btDelImage setHidden:NO];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"INVALIDmediaPost", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}


- (void)dealloc {
    [tb release];
    [btDone release];
    [tbHashtag release];
    [arrSearch release];
    [navBar release];
    [super dealloc];
}

@end
