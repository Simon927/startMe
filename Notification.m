//
//  Notification.m
//  startMe
//
//  Created by Matteo Gobbi on 19/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "Notification.h"

@implementation Notification

-(id)initWithId:(NSString *)id_notific type:(NSString *)type id_sender:(NSString *)id_sender sender_nickname:(NSString *)sender_nickname sender_name:(NSString *)sender_name sender_surname:(NSString *)sender_surname sender_image:(NSString *)sender_image id_receiver:(NSString *)id_receiver comment_id:(NSString *)comment_id post_id:(NSString *)post_id title_post:(NSString *)title_post descr_comment:(NSString *)descr_comment is_new:(NSString *)is_new timestamp:(NSString *)timestamp {
    
    self = [super init];
    if(self) {
        self.id_notific = id_notific;
        self.type = [type intValue];
        
        self.id_sender = id_sender;
        self.sender_name = sender_name;
        self.sender_surname = sender_surname;
        self.sender_nickname = sender_nickname;
        
        self.sender_image_name = sender_image;
        self.sender_image = [Utility getCachedImageFromPath:
                             [URL_SERVER stringByAppendingString:PATH_IMAGES_PROFILES_THUMBS]
                                                   withName:[Utility thumbForFilename:sender_image]];
        if(!self.sender_image) self.sender_image = IMG_PROFILE_DEFAULT;
        
        self.id_receiver = id_receiver;
        
        self.comment_id = comment_id;
        self.post_id = post_id;
        self.title_post = (title_post) ? title_post : @"";
        self.descr_comment = (descr_comment) ? descr_comment : @"";
        
        self.is_new = [is_new isEqualToString:@"1"];
        
        self.timestamp = [NSDate dateWithTimeIntervalSince1970:[timestamp intValue]];
        
        
        /* Preparo attributed string */
        NSAttributedString *type_article = nil, *type_string = nil, *type_title = nil, *type_final = nil;
        if(self.type == kNotificationTypeLike) {
            type_string = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"NOTIF_TYPE_LIKE", nil) attributes:@{
                                                  NSFontAttributeName:[UIFont systemFontOfSize:13],
                                       NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
            type_article = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"NOTIF_TYPE_LIKE_ARTICLE", nil) attributes:@{
                                                   NSFontAttributeName:[UIFont systemFontOfSize:13],
                                        NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
            type_title = [[[NSAttributedString alloc] initWithString:self.title_post attributes:@{
                                                 NSFontAttributeName:[UIFont italicSystemFontOfSize:13],
                                      NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
            type_final = [[[NSAttributedString alloc] initWithString:@"\"" attributes:@{
                                                 NSFontAttributeName:[UIFont italicSystemFontOfSize:13],
                                      NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
        } else if(self.type == kNotificationTypeComment) {
            type_string = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"NOTIF_TYPE_COMMENT", nil) attributes:@{
                                                  NSFontAttributeName:[UIFont systemFontOfSize:13],
                                       NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
            type_article = [[[NSAttributedString alloc] initWithString:@""] autorelease];
            type_title = [[[NSAttributedString alloc] initWithString:self.descr_comment attributes:@{
                                                 NSFontAttributeName:[UIFont italicSystemFontOfSize:13],
                                      NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
            type_final = [[[NSAttributedString alloc] initWithString:@"\"" attributes:@{
                                                 NSFontAttributeName:[UIFont italicSystemFontOfSize:13],
                                      NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
        } else if(self.type == kNotificationTypeFollowed) {
            type_string = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"NOTIF_TYPE_FOLLOWED", nil) attributes:@{
                                                  NSFontAttributeName:[UIFont systemFontOfSize:13],
                                       NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
            type_article = [[[NSAttributedString alloc] initWithString:@""] autorelease];
            type_title = [[[NSAttributedString alloc] initWithString:@"" attributes:@{
                                                 NSFontAttributeName:[UIFont italicSystemFontOfSize:13],
                                      NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
            type_final = [[[NSAttributedString alloc] initWithString:@"" attributes:@{
                                                 NSFontAttributeName:[UIFont italicSystemFontOfSize:13],
                                      NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
        } else if(self.type == kNotificationTypeTaggedPost || self.type == kNotificationTypeTaggedComment) {
            NSString *str = NSLocalizedString(@"NOTIF_TYPE_TAGGED_POST", nil);
            NSString *descr = self.title_post;
            if(self.type == kNotificationTypeTaggedComment) {
                str = NSLocalizedString(@"NOTIF_TYPE_TAGGED_COMMENT", nil);
                descr = self.descr_comment;
            }
            
            type_string = [[[NSAttributedString alloc] initWithString:str attributes:@{
                                                  NSFontAttributeName:[UIFont systemFontOfSize:13],
                                       NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
            type_article = [[[NSAttributedString alloc] initWithString:@"" attributes:@{
                                                   NSFontAttributeName:[UIFont systemFontOfSize:13],
                                        NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
            type_title = [[[NSAttributedString alloc] initWithString:descr attributes:@{
                                                 NSFontAttributeName:[UIFont italicSystemFontOfSize:13],
                                      NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
            type_final = [[[NSAttributedString alloc] initWithString:@"\"" attributes:@{
                                                 NSFontAttributeName:[UIFont italicSystemFontOfSize:13],
                                      NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}] autorelease];
        }
        
        NSString *name = [NSString stringWithFormat:@"%@ %@ ",self.sender_name,self.sender_surname];
        
        _attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:type_article];
        [_attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:name attributes:@{
                                                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:13],
                                                      NSForegroundColorAttributeName:NOTIFICATION_TEXT_COLOR}]];
        [_attributedString appendAttributedString:type_string];
        [_attributedString appendAttributedString:type_title];
        [_attributedString appendAttributedString:type_final];
        /*******/
    }
    return self;
}


-(id)initWithEncryptedDictonary:(NSDictionary *)n {
    return [self initWithId:[Utility decryptString:[n valueForKey:@"id"]]
                       type:[Utility decryptString:[n valueForKey:@"type"]]
                  id_sender:[Utility decryptString:[n valueForKey:@"id_sender"]]
            sender_nickname:[Utility decryptString:[n valueForKey:@"sender_nickname"]]
                sender_name:[Utility decryptString:[n valueForKey:@"sender_name"]]
             sender_surname:[Utility decryptString:[n valueForKey:@"sender_surname"]]
               sender_image:[Utility decryptString:[n valueForKey:@"sender_image"]]
                id_receiver:[Utility decryptString:[n valueForKey:@"id_receiver"]]
                 comment_id:[Utility decryptString:[n valueForKey:@"comment_id"]]
                    post_id:[Utility decryptString:[n valueForKey:@"post_id"]]
                 title_post:[Utility decryptString:[n valueForKey:@"title_post"]]
              descr_comment:[Utility decryptString:[n valueForKey:@"descr_comment"]]
                     is_new:[Utility decryptString:[n valueForKey:@"is_new"]]
                  timestamp:[Utility decryptString:[n valueForKey:@"timestamp"]]];
}


-(id)initWithDictonary:(NSDictionary *)n {
    return [self initWithId:[n valueForKey:@"id"]
                       type:[n valueForKey:@"type"]
                  id_sender:[n valueForKey:@"id_sender"]
            sender_nickname:[n valueForKey:@"sender_nickname"]
                sender_name:[n valueForKey:@"sender_name"]
             sender_surname:[n valueForKey:@"sender_surname"]
               sender_image:[n valueForKey:@"sender_image"]
                id_receiver:[n valueForKey:@"id_receiver"]
                 comment_id:[n valueForKey:@"comment_id"]
                    post_id:[n valueForKey:@"post_id"]
                 title_post:[n valueForKey:@"title_post"]
              descr_comment:[n valueForKey:@"descr_comment"]
                     is_new:[n valueForKey:@"is_new"]
                  timestamp:[n valueForKey:@"timestamp"]];
}



-(NSMutableDictionary *)toDictionary {
    NSArray *arrObjs = [NSArray arrayWithObjects:
                   _id_notific,
                   [NSString stringWithFormat:@"%d",_type],
                   _id_sender,
                   _sender_nickname,
                   _sender_name,
                   _sender_surname,
                   _sender_image_name,
                   _id_receiver,
                   _post_id,
                   _comment_id,
                   _title_post,
                   _descr_comment,
                   (_is_new) ? @"1" : @"0",
                   [NSString stringWithFormat:@"%d",(int)[_timestamp timeIntervalSince1970]],
                   nil];
    
    NSArray *arrKeys = [NSArray arrayWithObjects:
                        @"id",
                        @"type",
                        @"id_sender",
                        @"sender_nickname",
                        @"sender_name",
                        @"sender_surname",
                        @"sender_image",
                        @"id_receiver",
                        @"post_id",
                        @"comment_id",
                        @"title_post",
                        @"descr_comment",
                        @"is_new",
                        @"timestamp",
                        nil];
    
    return [NSMutableDictionary dictionaryWithObjects:arrObjs forKeys:arrKeys];
}

-(void)dealloc {
    [super dealloc];
    [_id_notific release];
    [_id_sender release];
    [_sender_nickname release];
    [_sender_name release];
    [_sender_image_name release];
    [_sender_surname release];
    [_id_receiver release];
    [_comment_id release];
    [_post_id release];
    [_title_post release];
    [_descr_comment release];
    [_timestamp release];
}

@end
