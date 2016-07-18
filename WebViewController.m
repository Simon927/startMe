//
//  WebViewController.m
//  startMe
//
//  Created by Matteo Gobbi on 22/08/13.
//  Copyright (c) 2013 Matteo Gobbi. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize urlRequest = _urlRequest;


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.backBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@""
                                      style:UIBarButtonItemStylePlain
                                     target:nil
                                     action:nil] autorelease];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{
                              UITextAttributeFont:NAVBAR_FONT,
                              UITextAttributeTextColor:NAVBAR_TITLE_COLOR,
                              }];
    
    [self startModeLoadingWithText:NSLocalizedString(@"Loading", nil)];
    [_webView loadRequest:_urlRequest];
    [self setTitle:_urlRequest.URL.absoluteString];
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView {
    [_btRefresh setEnabled:NO];
    [_btStop setEnabled:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self stopModeLoading];
    [_btRefresh setEnabled:YES];
    [_btStop setEnabled:NO];
    
    [_btBack setEnabled:[webView canGoBack]];
    [_btNext setEnabled:[webView canGoForward]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self stopModeLoading];
    [_btRefresh setEnabled:YES];
    [_btStop setEnabled:NO];
}

- (IBAction)goBack:(id)sender {
    [_webView goBack];
}

- (IBAction)goNext:(id)sender {
    [_webView goForward];
}

- (IBAction)refresh:(id)sender {
    [_webView reload];
}

- (IBAction)stop:(id)sender {
    [_webView stopLoading];
}

- (void)dealloc {
    [_webView release];
    [_btBack release];
    [_btNext release];
    [_btRefresh release];
    [_btStop release];
    [super dealloc];
}

@end
