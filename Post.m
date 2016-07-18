//
//  Post.m
//  startMe
//
//  Created by Matteo Gobbi on 08/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "Post.h"

@implementation Post

-(id)initWithId:(NSString *)post_id title:(NSString *)title 
descr:(NSString *)descr image:(NSString *)image mediaLink:(NSString *)mediaLink timestamp:(NSString *)timestamp tot_likes:(int)tot_likes like_me:(NSString *)like_me tot_comments:(int)tot_comments user_id:(NSString *)user_id nickname:(NSString *)nickname name:(NSString *)name surname:(NSString *)surname imgProfile:(NSString *)imgProfile email:(NSString *)email {
    
    self = [super init];
    if(self) {
        self.post_id = post_id;
        self.user_id = user_id;
        self.nickname = nickname;
        self.title = title;
        self.descr = descr;
        self.strImage = image;
        self.mediaLink = mediaLink;
        //self.image = (image && ![image isEqualToString:@""]) ? [Utility getCachedImageFromPath:[URL_SERVER stringByAppendingString:PATH_IMAGES_POSTS] withName:image] : nil;
        
        self.timestamp = [NSDate dateWithTimeIntervalSince1970:[timestamp intValue]];
        
        self.tot_likes = tot_likes;
        self.like_me = ![like_me isEqualToString:@""];
        self.tot_comments = tot_comments;
        self.name = name;
        self.surname = surname;
        if (imgProfile && ![imgProfile isEqualToString:@""]) {
            
          self.imgProfile = [Utility getCachedImageFromPath:[URL_SERVER stringByAppendingString:PATH_IMAGES_PROFILES_THUMBS] withName:[Utility thumbForFilename:imgProfile]];
            
        }
        
        if(!self.imgProfile) self.imgProfile = IMG_PROFILE_DEFAULT;
        
        self.email = email;
    }
    return self;
}

-(void)dealloc {
    [super dealloc];
    [_mediaLink release];
    [_post_id release];
    [_user_id release];
    [_nickname release];
    [_title release];
    [_descr release];
    [_image release];
    [_strImage release];
    [_imgProfile release];
    [_timestamp release];
    [_name release];
    [_surname release];
    [_email release];
}

@end
