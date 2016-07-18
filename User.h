//
//  User.h
//  startMe
//
//  Created by Matteo Gobbi on 28/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject


@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *surname;
@property (nonatomic, retain) UIImage *imgProfile;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *count_p;
@property (nonatomic, retain) NSString *count_fwers;
@property (nonatomic, retain) NSString *count_fwing;
@property BOOL is_followed;

//Set only if necessary
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *facebook;


-(id)initWithId:(NSString *)user_id is_followed:(NSString *)is_followed name:(NSString *)name
        surname:(NSString *)surname email:(NSString *)email img_profile:(NSString *)img_profile count_p:(NSString *)count_p count_fwers:(NSString *)count_fwers count_fwing:(NSString *)count_fwing;

-(id)initWithEncryptedDictonary:(NSDictionary *)dict;

-(NSMutableDictionary *)toDictionary;

@end
