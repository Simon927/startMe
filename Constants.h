//
//  Constants.h
//  startMe
//
//  Created by Matteo Gobbi on 11/01/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//


//Key
#define kKey @"a16byteslongkey!a16byteslongkey!"


//URL of the domain where you have upload PHP files
#define URL_SERVER @"http://www.startme.matteogobbi.it/"

//Remote PATH
#define PATH_IMAGES_PROFILES @"images/profiles/"                //Relative path to the folder for users's profile's images
#define PATH_IMAGES_PROFILES_THUMBS @"images/profiles/thumbs/"  //Relative path to the folder for thumbnail users's profile's images
#define PATH_IMAGES_POSTS @"images/posts/"                      //Relative path to the folder for users's posts's images

//Title app
#define APP_TITLE @"startMe"    //Name of the app (appears in the navigation's bar of the main view)


//Image profile size: the profile image is scaled and uploaded on the server, with the follow size
#define IMG_PROFILE_BIG_SCALE_W 160.0   //Profile's image whidth
#define IMG_PROFILE_BIG_SCALE_H 160.0   //Profile's image heigth (is recommended the same of the width)

//This field, allow you to set borders's images's profiles.
//For example:
//if you set it to 100, the border will be 1 pixel of width for images with size 100x100; 2 for images 200x200 etc. (scale 1 : 100);
//if you set it to 50 (scale 1 : 50), images of size 100x100, will have the border of 2 pixel of width.
#define IMG_PROFILE_BORDER_SCALE 50.0

#define IMG_PROFILE_QUALITY 1.0 //The quality of the image when it is converted before the upload on the server. (0.0 to 1.0)

//Others
#define IMG_PROFILE_DEFAULT [UIImage imageNamed:@"default_profile.png"] //Name of the default profile's image imported in the project (you can find this in the "Images -> Default Images" folder
#define MAX_SAVED_NOTIFICATIONS 30  //The max number of notifications stored in the app (if there are any new notifications for more than this number, they will still saved them all)

//Fonts and colors
#define APP_STATUS_BAR_STYLE UIStatusBarStyleLightContent  //The status bar style: UIStatusBarStyleLightContent; UIStatusBarStyleBlackOpaque; UIStatusBarStyleBlackTranslucent; UIStatusBarStyleDefault;
#define APP_TITLE_FONT @"ReklameScript-RegularDEMO"        //App font title (used in the navigation's bar of the main view)
#define APP_FONT @"ArialRoundedMTBold"                     //Used in other parts of the app as for example the labels in Profile view and others principal labels or buttons. Is recommended set the font most used in the app
#define APP_PLACEHOLDER_TEXT_COLOR [UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0]    //The color of the placeholder in textfield and textview

#define NOTIFICATION_TEXT_COLOR [UIColor colorWithWhite:0.35 alpha:1.0]                                            //The color of the notification's text in the NotificationViewController
#define NOTIFICATION_NEW_COLOR [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:220.0/255.0 alpha:1.0]     //The background color of new notifications

//NavBar Colors & Font
#define NAVBAR_BACKGROUND_COLOR [UIColor colorWithRed:0.0/255.0 green:131.0/255.0 blue:216.0/255.0 alpha:1.0]       //The color of the background of all navbars
#define NAVBAR_FONT [UIFont fontWithName:APP_FONT size:18]                                                          //The navbar font: you have to just edit size if you want (font name is editable above)
#define NAVBAR_TITLE_COLOR [UIColor whiteColor]                                                                     //The color of the titles in the navbars
#define NAVBAR_BUTTON_COLOR [UIColor whiteColor]                                                                    //The color of the buttons in the navbars

//Post
#define POST_DESCR_MIN_LENGHT 5     //Min length of a post description
#define POST_TITLE_MIN_LENGHT 3     //Min length of a post title
#define POST_DESCR_MAX_LENGHT 450   //Max length of a post description
#define POST_TITLE_MAX_LENGHT 25    //Max length of a post title
#define COMMENT_MAX_LENGHT 300      //Max length of a comment
#define POST_MAX_LENGHT_DESCR_IN_LIST_WITH_IMAGE 100    //Max length of a post description when is showed in the lists of the posts and the post has also the image. For see the complete description the user must open the individual post

//The indexs of the viewControllers in tabViewController: if you want change the disposition of viewControllers,
//you must first edit them from the Storyboard, and after edit this number. Remember that the center tab for share a new
//post must remain in the center (index 2). You can just edit the indexs 0, 1, 3, 4.
#define INDEX_OF_EXPLORE 0
#define INDEX_OF_FOLLOWING 1
#define INDEX_OF_NOTIFICATIONS 3
#define INDEX_OF_PROFILE 4







/*****It would be preferable not to modify the following fields*******/

typedef enum : NSUInteger {
    kListTypeNone,   //not used
    kListTypeSearch, //not used
    kListTypeFollowing,
    kListTypeFollowers,
    kListTypeLike
} ListType;


typedef enum : NSUInteger {
    kTypeMatchingFacebook,
    kTypeMatchingAddressBook
} TypeMatching;

//Type
#define TYPE_POSTS_ALL @"-3"
#define TYPE_POSTS_HASHTAG @"-2"
#define TYPE_POSTS_FOLLOWED @"-1"

//Error
#define ERROR_KEY @"error"
#define ERROR_CONNECTION @"-2"

//Services
#define SERVICE_CHANGE_IMG_PROFILE @"change_image_profile"
#define SERVICE_LOGOUT @"logout"
#define SERVICE_POST @"post"
#define SERVICE_COMMENT @"comment"
#define SERVICE_SYNC_CONTACTS @"sync_contacts"
#define SERVICE_GET_NOTIFICATIONS @"get_notifications"
#define SERVICE_FOLLOW @"follow"
#define SERVICE_SEARCH_USERS @"search_users"
#define SERVICE_DELETE_POST @"delete_post"
#define SERVICE_DELETE_COMMENT @"delete_comment"
#define SERVICE_EDIT_PROFILE @"edit_profile"
#define SERVICE_CONNECT_FACEBOOK @"connect_fb"

//Device
#define DEVICE_APP_ID @"DeviceAppId"
#define DEVICE_PUSH_TOKEN @"DeviceToken"

//User temp
#define USER_SESSION @"UserSession"
#define USER_FACEBOOK_LOGIN @"UserFacebookLogin"
#define USER_IMG_PROFILE @"UserImageProfile"
#define USER_ID @"UserId"
#define USER_NICKNAME @"UserNickname"
#define USER_TEMPFB_NICKNAME @"UserTempFbNickname"

//User FOR_EVER but relative
#define NOTIFICATIONS_DOWNLOADED [[Utility getUserId] stringByAppendingString:@"_notifications"]
#define NOTIFICATION_LAST_REFRESH [[Utility getUserId] stringByAppendingString:@"_notification_last_refresh"]
#define NOTIFICATION_LAST_READ [[Utility getUserId] stringByAppendingString:@"_notification_last_read"]
#define FOLLOWED_LAST_REFRESH [[Utility getUserId] stringByAppendingString:@"_followed_last_refresh"]
#define FOLLOWED_DOWNLOADED [[Utility getUserId] stringByAppendingString:@"_followed"]

//User FOR EVER
#define USER_RELATIVE_ALREDY_SENT @"UserAlredySent" //not used at the moment
#define TAGS_DOWNLOADED @"tags"

//Global cell identifier
#define POST_TITLE_CELL_ID @"PostTitleCellId"
#define POST_CELL_ID @"PostCellId"
#define POST_IMAGE_CELL_ID @"PostImageCellId"
#define POST_WEBVIEW_CELL_ID @"PostWebViewCellId"
#define USER_CELL_ID @"UserCellId"

/***********************************************************************/
