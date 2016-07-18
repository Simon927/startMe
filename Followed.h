//
//  Followed.h
//  startMe
//
//  Created by Matteo Gobbi on 05/09/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

@interface Followed : NSObject

@property (nonatomic, retain) NSString *id_relation;
@property (nonatomic, retain) NSString *followed_id;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *surname;
@property (nonatomic, retain) UIImage *imgProfile;
@property (nonatomic, retain) NSString *imgProfile_name;
@property BOOL is_followed;


-(id)initWithId:(NSString *)id_relation is_followed:(NSString *)is_followed followed_id:(NSString *)followed_id nickname:(NSString *)nickname name:(NSString *)name
        surname:(NSString *)surname img_profile:(NSString *)img_profile;

-(id)initWithEncryptedDictonary:(NSDictionary *)dict;
-(id)initWithDictonary:(NSDictionary *)dict;
-(NSMutableDictionary *)toDictionary;

@end
