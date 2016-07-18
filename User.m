//
//  User.m
//  startMe
//
//  Created by Matteo Gobbi on 28/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "User.h"

@implementation User

-(id)initWithId:(NSString *)user_id is_followed:(NSString *)is_followed name:(NSString *)name
          surname:(NSString *)surname email:(NSString *)email img_profile:(NSString *)img_profile count_p:(NSString *)count_p count_fwers:(NSString *)count_fwers count_fwing:(NSString *)count_fwing {
    
    self = [super init];
    if(self) {
        self.user_id = (user_id) ? user_id : @"";
        self.is_followed = ([is_followed isEqualToString:@""] || [is_followed isEqualToString:@"0"]) ? NO : YES;
        self.name = (name) ? name : @"";
        self.surname = (surname) ? surname : @"";
        self.email = (email) ? email : @"";
        self.imgProfile = [Utility getCachedImageFromPath:[URL_SERVER stringByAppendingString:PATH_IMAGES_PROFILES] withName:img_profile];
        if(!self.imgProfile) self.imgProfile = IMG_PROFILE_DEFAULT;
        self.count_p = ([count_p isEqualToString:@""] || !count_p) ? @"0" : count_p;
        self.count_fwers = ([count_fwers isEqualToString:@""] || !count_fwers) ? @"0" : count_fwers;
        self.count_fwing = ([count_fwing isEqualToString:@""] || !count_fwing) ? @"0" : count_fwing;
        
    }
    return self;
}

-(id)initWithEncryptedDictonary:(NSDictionary *)dict {
    self = [self initWithId:[Utility decryptString:[dict valueForKey:@"id"]]
                is_followed:[Utility decryptString:[dict valueForKey:@"is_followed"]]
                       name:[Utility decryptString:[dict valueForKey:@"name"]]
                  surname:[Utility decryptString:[dict valueForKey:@"surname"]]
                email:[Utility decryptString:[dict valueForKey:@"email"]]
             img_profile:[Utility decryptString:[dict valueForKey:@"img_profile"]]
                 count_p:[Utility decryptString:[dict valueForKey:@"count_p"]]
                    count_fwers:[Utility decryptString:[dict valueForKey:@"count_fwers"]]
                 count_fwing:[Utility decryptString:[dict valueForKey:@"count_fwing"]]];

    self.nickname = [Utility decryptString:[dict valueForKey:@"nickname"]];
    self.facebook = [Utility decryptString:[dict valueForKey:@"facebook"]];
    
    return self;
}


-(NSMutableDictionary *)toDictionary {
    NSArray *arrObjs = [NSArray arrayWithObjects:
                        _user_id,
                        (_is_followed) ? @"1" : @"0",
                        _name,
                        _surname,
                        _email,
                        UIImageJPEGRepresentation(_imgProfile, 1.0),
                        _count_p,
                        _count_fwers,
                        _count_fwing,
                        nil];
    
    NSArray *arrKeys = [NSArray arrayWithObjects:
                        @"id",
                        @"is_followed",
                        @"name",
                        @"surname",
                        @"email",
                        @"img_profile",
                        @"count_p",
                        @"count_fwers",
                        @"count_fwing",
                        nil];
    
    return [NSMutableDictionary dictionaryWithObjects:arrObjs forKeys:arrKeys];
}

-(void)dealloc {
    [_user_id release];
    [_name release];
    [_surname release];
    [_email release];
    [_nickname release];
    [_imgProfile release];
    [_count_fwers release];
    [_count_p release];
    [_count_fwing release];
    [super dealloc];
}


@end
