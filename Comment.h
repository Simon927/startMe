//
//  Comment.h
//  startMe
//
//  Created by Matteo Gobbi on 10/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "Post.h"

@interface Comment : Post

@property (nonatomic, retain) NSString *comment_id;

@property float textHeight;

-(id)initWithId:(NSString *)comment_id post_id:(NSString *)post_id
          descr:(NSString *)descr timestamp:(NSString *)timestamp user_id:(NSString *)user_id nickname:(NSString *)nickname name:(NSString *)name surname:(NSString *)surname imgProfile:(NSString *)imgProfile;

@end
