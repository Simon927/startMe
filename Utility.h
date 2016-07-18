//
//  Utility.h
//  startMe
//
//  Created by Matteo Gobbi on 21/12/12.
//  Copyright (c) 2012 Matteo Gobbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

#import "NSData+Base64.h"
#import "FBEncryptorAES.h"


@interface Utility : NSObject
{
    
}

+ (NSString *)encryptString:(NSString *)string;
+ (NSString *)decryptString:(NSString*)ciphertext;
+ (NSString *) encryptData:(NSData *)data urlEncode:(BOOL)encode;
+ (NSData *) decryptStringToData:(NSString*)ciphertext;
+ (NSString *) URLEncodedString_ch:(NSString *)string;
+ (NSString *) getDeviceAppId;
+ (NSString *) getDeviceToken;
+ (NSString *) getSession;
+ (NSString *)getUserId;
+ (NSString *)getNickname;
+ (NSMutableArray *)getNotifications;

+ (NSMutableArray *)getTags;
+ (NSMutableArray *)getFollowed;

+ (BOOL)userIsLogged;

+ (void) setDefaultValue:(NSString *)value forKey:(NSString *)key;
+ (NSString *) getDefaultValueForKey:(NSString *)key;
+ (void) setDefaultObject:(NSObject *)object forKey:(NSString *)key;
+ (NSObject *) getDefaultObjectForKey:(NSString *)key;

+ (NSString *)getKey:(NSString *)key forUserId:(NSString *)user_id;

+ (NSString*)formatNumber:(NSString*)mobileNumber;

+ (void) toggleNetworkActivityIndicatorVisible:(BOOL)visible;
+ (BOOL)isImageProfileSetted;

+ (BOOL)isFacebookConnected;

+ (UIImage *)getProfileImage;

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;

+ (UIImage *) getCachedImageFromPath:(NSString *)PathURL withName:(NSString *)filename;
+ (void) getCachedImageFromPath:(NSString *)PathURL withName:(NSString *)filename
                   forIndexPath:(NSIndexPath *)indexPath completion:(void (^)(UIImage *image, NSIndexPath *indexPath))completion;

+ (NSString *)thumbForFilename:(NSString *)filename;

+ (NSString *)getAppVersion;

+ (BOOL)stringIsValid:(NSString *)str regex:(NSString *)regex;

+ (NSString *)getYoutubeVideoID:(NSString *)url;

@end