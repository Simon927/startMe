//
//  WebViewController.h
//  startMe
//
//  Created by Matteo Gobbi on 22/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "CustomViewController.h"

@interface WebViewController : CustomViewController <UIWebViewDelegate> {
    NSURLRequest *urlRequest;
}

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) NSURLRequest *urlRequest;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btBack;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btNext;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btRefresh;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *btStop;

- (IBAction)goBack:(id)sender;
- (IBAction)goNext:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)stop:(id)sender;

@end
