//
//  ChooseProfileImageViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 31/12/12.
//  Copyright (c) 2012 Matteo Gobbi. All rights reserved.
//


#import "ChooseProfileImageViewController.h"

@interface ChooseProfileImageViewController ()

@end

@implementation ChooseProfileImageViewController

@synthesize imgProfile = _imgProfile;

-(void)initializeView {

    /****SET COLOR OF THE NAVBAR****/
    [[self.view viewWithTag:99] setBackgroundColor:NAVBAR_BACKGROUND_COLOR];
    [[self.view viewWithTag:99] setAlpha:0.58];
    /************************/
    
    /***Set localized string***/
    [btDone setTitle:NSLocalizedString(@"btChooseImageDone", nil)];
    [btTakePhoto setTitle:NSLocalizedString(@"btTakePhoto", nil) forState:UIControlStateNormal];
    [btChoosePhoto setTitle:NSLocalizedString(@"btChoosePhoto", nil) forState:UIControlStateNormal];
    [btPhotoFacebook setTitle:NSLocalizedString(@"btPhotoFacebook", nil) forState:UIControlStateNormal];
    [btPhotoDefault setTitle:NSLocalizedString(@"btPhotoDefault", nil) forState:UIControlStateNormal];
    [navBar setTitle:NSLocalizedString(@"titleChooseImage", nil)];
    /********/
    
    
    [_txtNickname setEnabled:_modalityNick];
    [btCancel setEnabled:!_modalityNick];
    
    NSString *fb_login = [Utility getDefaultValueForKey:USER_FACEBOOK_LOGIN];
    [btPhotoFacebook setEnabled:!([fb_login isEqualToString:@""] || fb_login == nil)];
    
    if(!_modalityNick) _txtNickname.text = [Utility getNickname];

    UIImage *buttonImageTake = [[UIImage imageNamed:@"greyButton.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageTakeHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

    [btTakePhoto setBackgroundImage:buttonImageTake forState:UIControlStateNormal];
    [btTakePhoto setBackgroundImage:buttonImageTakeHighlight forState:UIControlStateHighlighted];
    
    [btChoosePhoto setBackgroundImage:buttonImageTake forState:UIControlStateNormal];
    [btChoosePhoto setBackgroundImage:buttonImageTakeHighlight forState:UIControlStateHighlighted];
    
    [btPhotoDefault setBackgroundImage:buttonImageTake forState:UIControlStateNormal];
    [btPhotoDefault setBackgroundImage:buttonImageTakeHighlight forState:UIControlStateHighlighted];

    [self initImageProfile];
}


#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES ;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initializeView];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clickDone:(id)sender {
    [self.view endEditing:YES];
    [self done];
}


-(void)done {
    
    //Only if controller isn't presented with curl
    [self startModeLoadingWithText:NSLocalizedString(@"Setting", nil)];
    
    NSString *device = [Utility encryptString:[Utility getDeviceAppId]];
    NSString *session = [Utility encryptString:[Utility getSession]];
    NSString *token = [Utility encryptString:[Utility getDeviceToken]];
    NSString *method = [Utility encryptString:SERVICE_CHANGE_IMG_PROFILE];
    
    //Scale image
    UIImage *image = [Utility scaleImage:_imgProfile.image toSize:CGSizeMake(IMG_PROFILE_BIG_SCALE_W, IMG_PROFILE_BIG_SCALE_H) ];
    
    //Save
    img_data = UIImageJPEGRepresentation(image, IMG_PROFILE_QUALITY);
    
    NSString *str = [URL_SERVER stringByAppendingString:@"request.php"];
    
    //Start parser thread
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
    [request setPostValue:device forKey:@"device"];
    [request setPostValue:session forKey:@"session"];
    [request setPostValue:token forKey:@"token"];
    [request setPostValue:[Utility encryptString:[Utility getAppVersion]] forKey:@"app_version"];
    [request setPostValue:method forKey:@"method"];
    [request setData:img_data withFileName:@"image" andContentType:@"image/jpeg" forKey:@"photo"];
    
    //If i'm sending also nickname
    if(_modalityNick) {
        //Save nickname
        nickname = _txtNickname.text;
        //Nickname encoded
        NSString *nickname_encrypted = [Utility encryptString:nickname];
        [request setPostValue:nickname_encrypted forKey:@"nick"];
    }

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
            //Session valid
            NSString *response = [responseDict valueForKey:@"response"];
            
            if([response isEqualToString:@"-1"]) {
                //Show alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            } else if([response isEqualToString:@"1"]) {
                //Save image profile in the userdefault
                [Utility setDefaultObject:img_data forKey:USER_IMG_PROFILE];
                
                //Controllo nick
                NSString *nick_status = [responseDict valueForKey:@"nick_status"];
                
                if(nick_status) {
                    if ([nick_status isEqualToString:@"OKnick"]) {
                        //Save nickname in the userdefault
                        [Utility setDefaultValue:_txtNickname.text forKey:USER_NICKNAME];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    } else if ([nick_status isEqualToString:@"INVALIDnick"]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"INVALIDnick", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        [alert release];
                    } else if ([nick_status isEqualToString:@"EXISTnick"]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"EXISTnick", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        [alert release];
                    } else if ([nick_status isEqualToString:@"-1"]) {
                        //Show alert
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server error", nil) message:NSLocalizedString(@"messageDatabaseError", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        [alert release];
                    }
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    if (!_modalityNick) {
                        [_delegate refresh];
                    }
                }
            }
            
        } else if([logged isEqualToString:@"OLDappVersion"]) {
            //Show alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_TITLE message:NSLocalizedString(@"messageVersionOld", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [[DataManager getInstance] logout];
            UIViewController *c = self.presentingViewController.presentingViewController;
            [c dismissViewControllerAnimated:YES completion:nil];
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
            UIViewController *c = self.presentingViewController.presentingViewController;
            [c dismissViewControllerAnimated:YES completion:nil];
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

                            
//Disabilita i comandi e attiva il loading grafico
-(void)setModeLoading:(BOOL)active withText:(NSString *)string {
    [super setModeLoading:active withText:string];
    
    btChoosePhoto.enabled = !active;
    btTakePhoto.enabled = !active;
    btDone.enabled = !active;
    btPhotoDefault.enabled = !active;

}


-(IBAction)takePhotoClick:(id)sender {
    
    int tag = ((UIButton*)sender).tag;
    
    if(tag == 2) {
        [_imgProfile setImage:IMG_PROFILE_DEFAULT];
        return;
    } else if(tag == 3) {

        [self imageFromFacebook];
        
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];

    picker.delegate = self;
    
    if (tag == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else return;
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (IBAction)clickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *) picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [picker release];
    
    [[UIApplication sharedApplication] setStatusBarStyle:APP_STATUS_BAR_STYLE];
    
}


- (void)imagePickerController:(UIImagePickerController *) picker

didFinishPickingMediaWithInfo:(NSDictionary *)info {

    [_imgProfile setImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [picker release];
    
    [[UIApplication sharedApplication] setStatusBarStyle:APP_STATUS_BAR_STYLE];
}


-(void)initImageProfile {
    UIImage *im_profile = [UIImage imageWithData:(NSData *)[Utility getDefaultObjectForKey:USER_IMG_PROFILE]];
    
    if (!im_profile) {
        //Controllo se devo scaricare l'immagine di facebook
        NSString *fb_login = [Utility getDefaultValueForKey:USER_FACEBOOK_LOGIN];
        if(![fb_login isEqualToString:@""] && fb_login != nil) {
            
            //Setto nickname temporaneo
            [_txtNickname setText:[[Utility getDefaultValueForKey:USER_TEMPFB_NICKNAME] stringByReplacingOccurrencesOfString:@"." withString:@"_"]];
            
            [self imageFromFacebook];
            return;
            
        } else {
            im_profile = IMG_PROFILE_DEFAULT;
        }
    }
    
    [_imgProfile setImage:im_profile];
    
    
}


- (void)imageFromFacebook {
    [self startModeLoadingWithText:NSLocalizedString(@"messageDownloadFacebook", nil)];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^(void) {
        
        NSString *fb_login = [Utility getDefaultValueForKey:USER_FACEBOOK_LOGIN];
        NSString *url_image = [NSString stringWithFormat:@"http://graph.facebook.com/%@",fb_login];
        url_image = [url_image stringByAppendingString:@"/picture?type=large"];
        
        NSData *imageProfileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url_image]];
        
        UIImage *image = [UIImage imageWithData:imageProfileData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_imgProfile setImage:image];
            [self stopModeLoading];
        });
        
    });
    
    
}


- (void)dealloc {
    [_imgProfile release];
    [_txtNickname release];
    [btPhotoFacebook release];
    [navBar release];
    [super dealloc];
}


@end
