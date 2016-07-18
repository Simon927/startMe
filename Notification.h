//
//  Notification.h
//  startMe
//
//  Created by Matteo Gobbi on 19/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kNotificationTypeLike,
    kNotificationTypeComment,
    kNotificationTypeFollowed,
    kNotificationTypeTaggedPost,
    kNotificationTypeTaggedComment
} NotificationType;

@interface Notification : NSObject

@property (nonatomic, retain) NSString *id_notific;
@property NotificationType type;
@property (nonatomic, retain) NSString *id_sender;
@property (nonatomic, retain) NSString *sender_name;
@property (nonatomic, retain) NSString *sender_surname;
@property (nonatomic, retain) NSString *sender_nickname;
@property (nonatomic, retain) UIImage *sender_image;
@property (nonatomic, retain) NSString *sender_image_name;
@property (nonatomic, retain) NSString *id_receiver;
@property (nonatomic, retain) NSString *post_id;
@property (nonatomic, retain) NSString *comment_id;
@property (nonatomic, retain) NSString *title_post;
@property (nonatomic, retain) NSString *descr_comment;
@property BOOL is_new;
@property (nonatomic, retain) NSDate *timestamp;
@property (nonatomic, retain) NSMutableAttributedString *attributedString;

-(id)initWithId:(NSString *)id_notific type:(NSString *)type id_sender:(NSString *)id_sender sender_nickname:(NSString *)sender_nickname sender_name:(NSString *)sender_name sender_surname:(NSString *)sender_surname sender_image:(NSString *)sender_image id_receiver:(NSString *)id_receiver comment_id:(NSString *)comment_id post_id:(NSString *)post_id title_post:(NSString *)title_post descr_comment:(NSString *)descr_comment is_new:(NSString *)is_new timestamp:(NSString *)timestamp;
-(id)initWithEncryptedDictonary:(NSDictionary *)n;
-(id)initWithDictonary:(NSDictionary *)n;

-(NSMutableDictionary *)toDictionary;


@end
