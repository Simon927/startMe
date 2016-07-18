//
//  Comment.m
//  startMe
//
//  Created by Matteo Gobbi on 10/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "Comment.h"

@implementation Comment

-(id)initWithId:(NSString *)comment_id post_id:(NSString *)post_id
          descr:(NSString *)descr timestamp:(NSString *)timestamp user_id:(NSString *)user_id nickname:(NSString *)nickname name:(NSString *)name surname:(NSString *)surname imgProfile:(NSString *)imgProfile {
    
    self = [super init];
    if(self) {
        self.comment_id = comment_id;
        self.post_id = post_id;
        self.user_id = user_id;
        self.nickname = nickname;
        self.descr = descr;
        
        self.timestamp = [NSDate dateWithTimeIntervalSince1970:[timestamp intValue]];
        
        self.name = name;
        self.surname = surname;
        if (imgProfile && ![imgProfile isEqualToString:@""]) {
            self.imgProfile = [Utility getCachedImageFromPath:[URL_SERVER stringByAppendingString:PATH_IMAGES_PROFILES_THUMBS] withName:[Utility thumbForFilename:[Utility decryptString:imgProfile]]];
        }
        if(!self.imgProfile) self.imgProfile = IMG_PROFILE_DEFAULT;
    }
    return self;
}

-(void)dealloc {
    [_comment_id release];
    [super dealloc];
}

@end
