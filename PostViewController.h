//
//  PostViewController.h
//  startMe
//
//  Created by Matteo Gobbi on 10/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

//#import "RefreshTableViewController.h"
#import "Post.h"
#import "STTweetLabel.h"

#import "THChatInput.h"

@interface PostViewController : CustomViewController <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet CustomTableView *tableList;
@property (retain, nonatomic) IBOutlet UITableView *tbHashtag;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, assign) Post *post;

@property (retain, nonatomic) IBOutlet THChatInput *chatInput;

@property BOOL clickComment;
@property BOOL postedComment;

@property int downloadPostID;

//This property is used when the user enter in this viewController by clicking on the notification cell
@property (nonatomic,assign) NSString *notifCommentId;

@end
