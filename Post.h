//
//  Post.h
//  startMe
//
//  Created by Matteo Gobbi on 08/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

//Post property
@property (nonatomic, retain) NSString *post_id;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *descr;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *strImage;
@property (nonatomic, retain) NSString *mediaLink;
@property (nonatomic, retain) NSDate *timestamp;
@property int tot_likes;
@property int tot_comments;
@property BOOL like_me;

//User property
@property (nonatomic, retain) NSString *user_id;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *surname;
@property (nonatomic, retain) UIImage *imgProfile;
@property (nonatomic, retain) NSString *email;

@property float textHeight;

-(id)initWithId:(NSString *)post_id title:(NSString *)title
          descr:(NSString *)descr image:(NSString *)image mediaLink:(NSString *)mediaLink timestamp:(NSString *)timestamp tot_likes:(int)tot_likes like_me:(NSString *)like_me tot_comments:(int)tot_comments user_id:(NSString *)user_id nickname:(NSString *)nickname name:(NSString *)name surname:(NSString *)surname imgProfile:(NSString *)imgProfile email:(NSString *)email;

@end
