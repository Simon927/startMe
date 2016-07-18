  //
//  Followed.m
//  startMe
//
//  Created by Matteo Gobbi on 05/09/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "Followed.h"

@implementation Followed

-(id)initWithId:(NSString *)id_relation is_followed:(NSString *)is_followed followed_id:(NSString *)followed_id nickname:(NSString *)nickname name:(NSString *)name
        surname:(NSString *)surname img_profile:(NSString *)img_profile {
    
    self = [super init];
    if(self) {
        self.id_relation = (id_relation) ? id_relation : @"";
        self.is_followed = ([is_followed isEqualToString:@""] || [is_followed isEqualToString:@""] || [is_followed isEqualToString:@"0"]) ? NO : YES;
        self.followed_id = (followed_id) ? followed_id : @"";
        self.nickname = (nickname) ? nickname : @"";
        self.name = (name) ? name : @"";
        self.surname = (surname) ? surname : @"";
        self.imgProfile_name = img_profile;
        self.imgProfile = [Utility getCachedImageFromPath:
                           [URL_SERVER stringByAppendingString:PATH_IMAGES_PROFILES_THUMBS]
                                                 withName:[Utility thumbForFilename:img_profile]];
        if(!self.imgProfile) self.imgProfile = IMG_PROFILE_DEFAULT;
    }
    return self;
}


-(id)initWithEncryptedDictonary:(NSDictionary *)dict {
    return [self initWithId:[Utility decryptString:[dict valueForKey:@"id"]]
                is_followed:[Utility decryptString:[dict valueForKey:@"is_followed"]]
                 followed_id:[Utility decryptString:[dict valueForKey:@"followed_id"]]
                   nickname:[Utility decryptString:[dict valueForKey:@"nickname"]]
                       name:[Utility decryptString:[dict valueForKey:@"name"]]
                    surname:[Utility decryptString:[dict valueForKey:@"surname"]]
                img_profile:[Utility decryptString:[dict valueForKey:@"img_profile"]]];
    
}

-(id)initWithDictonary:(NSDictionary *)dict {
    return [self initWithId:[dict valueForKey:@"id"]
                is_followed:[dict valueForKey:@"is_followed"]
                followed_id:[dict valueForKey:@"followed_id"]
                   nickname:[dict valueForKey:@"nickname"]
                       name:[dict valueForKey:@"name"]
                    surname:[dict valueForKey:@"surname"]
                img_profile:[dict valueForKey:@"img_profile"]];
    
}


-(NSMutableDictionary *)toDictionary {

    NSArray *arrObjs = [NSArray arrayWithObjects:
                        _id_relation,
                        (_is_followed) ? @"1" : @"0",
                        _followed_id,
                        _nickname,
                        _name,
                        _surname,
                        _imgProfile_name,
                        nil];
    
    NSArray *arrKeys = [NSArray arrayWithObjects:
                        @"id",
                        @"is_followed",
                        @"followed_id",
                        @"nickname",
                        @"name",
                        @"surname",
                        @"img_profile",
                        nil];
    
    return [NSMutableDictionary dictionaryWithObjects:arrObjs forKeys:arrKeys];
}


-(void)dealloc {
    [_id_relation release];
    [_followed_id release];
    [_name release];
    [_surname release];
    [_imgProfile release];
    [_imgProfile_name release];
    [_nickname release];
    [super dealloc];
}


@end
