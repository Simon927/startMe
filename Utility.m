//
//  Utility.m
//  startMe
//
//  Created by Matteo Gobbi on 21/12/12.
//  Copyright (c) 2012 Matteo Gobbi. All rights reserved.
//

#define TMP NSTemporaryDirectory()

#import "Utility.h"
#import "Followed.h"


@implementation Utility

+ (NSString *) encryptString:(NSString*)plaintext {
    
    NSString *string = [FBEncryptorAES encryptBase64String:plaintext
                                                 keyString:kKey
                                             separateLines:NO];
    
	return string;
}


+ (NSString *) decryptString:(NSString*)ciphertext {
    if([ciphertext isEqualToString:@""] || !ciphertext) return ciphertext;
    return [FBEncryptorAES decryptBase64String:ciphertext keyString:kKey];
}


+ (NSString *) encryptData:(NSData *)data urlEncode:(BOOL)encode{
    
    NSString *string = [FBEncryptorAES encryptBase64Data:data
                                                 keyString:kKey
                                             separateLines:NO];
    
	return string;
}

+ (NSData *) decryptStringToData:(NSString*)ciphertext {
    return [FBEncryptorAES decryptBase64StringToData:ciphertext keyString:kKey];
}

+ (NSString *) URLEncodedString_ch:(NSString *)string {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    
    return output;
}


+ (NSString *) getDeviceAppId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults objectForKey:DEVICE_APP_ID];
    
    if (!value)
    {
        value = (NSString *) CFUUIDCreateString (NULL, CFUUIDCreate(NULL));
        [defaults setValue: value forKey: DEVICE_APP_ID];
        [defaults synchronize];
    }
    
    return value;
}

+ (NSString *) getDeviceToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults objectForKey:DEVICE_PUSH_TOKEN];
    
    if (!value)
    {
        value = @"";
        [defaults setValue:value forKey: DEVICE_PUSH_TOKEN];
        [defaults synchronize];
    }
    
    return value;
}

+ (NSString *)getSession
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults objectForKey:USER_SESSION];
    
    if (!value)
    {
        value = @"";
        [defaults setValue:value forKey: USER_SESSION];
        [defaults synchronize];
    }
    
    return value;
}

+ (NSString *)getUserId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults objectForKey:USER_ID];
    
    if (!value)
    {
        value = @"0";
        [defaults setValue:value forKey: USER_ID];
        [defaults synchronize];
    }
    
    return value;
}

+ (NSString *)getNickname
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults objectForKey:USER_NICKNAME];
    
    if (!value)
    {
        value = @"";
        [defaults setValue:value forKey: USER_NICKNAME];
        [defaults synchronize];
    }
    
    return value;
}


+ (NSMutableArray *)getTags
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrTags = [defaults objectForKey:TAGS_DOWNLOADED];
    
    if (!arrTags)
    {
        arrTags = [NSMutableArray arrayWithCapacity:0];
        [defaults setValue:arrTags forKey:TAGS_DOWNLOADED];
        [defaults synchronize];
    }
    
    return arrTags;
}

+ (NSMutableArray *)getFollowed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrFollowed = [defaults objectForKey:FOLLOWED_DOWNLOADED];
    
    if (!arrFollowed)
    {
        arrFollowed = [NSMutableArray arrayWithCapacity:0];
        [defaults setValue:arrFollowed forKey:FOLLOWED_DOWNLOADED];
        [defaults synchronize];
    }
    
    return arrFollowed;
}

+ (NSMutableArray *)getNotifications
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrNotific = [defaults objectForKey:NOTIFICATIONS_DOWNLOADED];
    
    if (!arrNotific)
    {
        arrNotific = [NSMutableArray arrayWithCapacity:0];
        [defaults setValue:arrNotific forKey:NOTIFICATIONS_DOWNLOADED];
        [defaults synchronize];
    }
    
    return arrNotific;
}


//General
+ (void) setDefaultValue:(NSString *)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

+ (NSString *) getDefaultValueForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults objectForKey:key];
    
    if (!value)
    {
        value = @"";
        [defaults setValue:value forKey: key];
        [defaults synchronize];
    }
    
    return value;
}

+ (void) setDefaultObject:(NSObject *)object forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}

+ (NSObject *) getDefaultObjectForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSObject *value = [defaults objectForKey:key];
    
    return value;
}


//Relative to user
+ (NSString *)getKey:(NSString *)key forUserId:(NSString *)user_id {
    return [[key stringByAppendingString:@"-"] stringByAppendingString:user_id]; //Ex. "alredySent-15"
}


//Formatting number (solo numero di telefono senza prefisso nazionale)
+(NSString *)formatNumber:(NSString*)mobileNumber {
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    if(length > 10) {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}


+(void) toggleNetworkActivityIndicatorVisible:(BOOL)visible {
    static int activityCount = 0;
    @synchronized (self) {
        visible ? activityCount++ : activityCount--;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = activityCount > 0;
    }
}

+ (BOOL)isImageProfileSetted {
    return [Utility getDefaultObjectForKey:USER_IMG_PROFILE];
}


+ (BOOL)isFacebookConnected {
    return ![[Utility getDefaultValueForKey:USER_FACEBOOK_LOGIN] isEqualToString:@""];;
}

+ (NSString *)getAppVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
}


typedef enum {
    GBPathImageViewTypeCircle,
    GBPathImageViewTypeSquare
} GBPathImageViewType;



+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize {
    CGSize actSize = image.size;
    float scale = actSize.width/actSize.height;
    
    if (scale < 1) {
        newSize.height = newSize.width/scale;
    } else {
        newSize.width = newSize.height*scale;
    }
    
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)getProfileImage {
    UIImage *image = [UIImage imageWithData:(NSData *)[Utility getDefaultObjectForKey:USER_IMG_PROFILE]];
    if(!image) image = IMG_PROFILE_DEFAULT;
    return image;
}

+ (BOOL)userIsLogged {
    return (![[Utility getSession] isEqualToString:@""]);
}

#pragma mark - Cached images

+ (void)cacheImageFromPath:(NSString *)PathURL withName:(NSString *)filename
{
    NSString *ImageURLString = [PathURL stringByAppendingString:filename];
    NSURL *ImageURL = [NSURL URLWithString:ImageURLString];
    
    // Generate a unique path to a resource representing the image you want
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    // Check for file existence
    if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        // The file doesn't exist, we should get a copy of it
        
        // Fetch image
        NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
        UIImage *image = [[UIImage alloc] initWithData: data];
        
        
        // Is it PNG or JPG/JPEG?
        // Running the image representation function writes the data from the image to a file
        if([ImageURLString rangeOfString: @".png" options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
        }
        else if(
                [ImageURLString rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound ||
                [ImageURLString rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound
                )
        {
            [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
        }
    }
}


+ (void) getCachedImageFromPath:(NSString *)PathURL withName:(NSString *)filename
                   forIndexPath:(NSIndexPath *)indexPath completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion {
    
    
}

+ (UIImage *) getCachedImageFromPath:(NSString *)PathURL withName:(NSString *)filename
{
    // Generate a unique path to a resource representing the image you want
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    UIImage *image;
    
    // Check for a cached version
    if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
    {
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    }
    else
    {
        // get a new one
        [self cacheImageFromPath:PathURL withName:filename];
        image = [UIImage imageWithContentsOfFile: uniquePath];
    }
    
    return image;
}


+ (NSString *)thumbForFilename:(NSString *)filename {
    if(!filename || [filename length] == 0) return @"";
    
    NSString *thumb_filename = @"";
    
    NSArray *arr = [filename componentsSeparatedByString:@"."];
    
    for(int i=0; i<[arr count]-1; i++) {
        thumb_filename = [thumb_filename stringByAppendingString:arr[i]];
        if (i != 0 && i != [arr count]-2) {
            [thumb_filename stringByAppendingString:@"."];
        }
    }
    
    thumb_filename = [[thumb_filename stringByAppendingString:@"-thumb."] stringByAppendingString:[arr lastObject]];
    return thumb_filename;
}

+ (BOOL)stringIsValid:(NSString *)str regex:(NSString *)regex {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:str];
}


+ (NSString*)getYoutubeVideoID:(NSString*)url {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([\\w_-]{11})(&.+)?"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:url
                                                    options:0
                                                      range:NSMakeRange(0, [url length])];
    NSString *substringForFirstMatch = nil;
    if (match) {
        NSRange videoIDRange = [match rangeAtIndex:0];
        substringForFirstMatch = [url substringWithRange:videoIDRange];
    }
    return substringForFirstMatch;
}


@end
