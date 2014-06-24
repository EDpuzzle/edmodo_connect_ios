//
//  EMConnectLoginViewController.m
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/16/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import "EMObjects.h"
#import "EMConnectDataStore.h"
#import "EMConnectLoginView.h"

@interface EMConnectLoginView ()

@end

@implementation EMConnectLoginView {
    UIWebView *_webView;
    NSString* _clientID;
    EMStringResultBlock_t _successHandler;
    EMVoidResultBlock_t _cancelHandler;
    EMNSErrorBlock_t _errorHandler;
}

static CGFloat const EC_WebViewHeight = 450;
static CGFloat const EC_WebViewWidth = 400;

static NSString* const EDMODO_CONNECT_LOGIN_BEGINNING = @"https://api.edmodo.com/oauth/authorize?";
static NSString* const EDMODO_CONNECT_LOGIN_MIDDLE = @"client_id=%@";
static NSString* const EDMODO_CONNECT_LOGIN_END = @"&redirect_uri=https%3A%2F%2Fapi.edmodo.com%2Fstatus-lb&response_type=token&scope=basic%20read_groups";

- (id)initWithFrame:(CGRect)rect
       withClientID:(NSString*)clientID
          onSuccess:(EMStringResultBlock_t)successHandler
           onCancel:(EMVoidResultBlock_t)cancelHandler
            onError:(EMNSErrorBlock_t)errorHandler {
    self = [super initWithFrame:rect];
    if (self) {
        _clientID = clientID;
        _successHandler = successHandler;
        _cancelHandler = cancelHandler;
        _errorHandler = errorHandler;
        
        [self __createWidgets];
    }
    return self;
}

- (void) setWebViewFrame:(CGRect)rect
{
    _webView.frame = rect;
}

- (void) __createWidgets
{
    self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    
    // create UIWebview at some nice size, centered.
    // Caller can overload if they want.
    CGFloat x = (self.frame.size.width - EC_WebViewWidth)/2;
    // Scoot it up above center to make room for keyboard
    CGFloat y = (self.frame.size.height - EC_WebViewHeight)/5;
    CGRect wvFrame = CGRectMake(x, y, EC_WebViewWidth, EC_WebViewHeight);
    
    _webView = [[UIWebView alloc]initWithFrame:wvFrame];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    
    
    // New EdmodoConnect API
    NSString* formattedMiddle = [NSString stringWithFormat:EDMODO_CONNECT_LOGIN_MIDDLE, _clientID];
    NSString* fullURL = [[EDMODO_CONNECT_LOGIN_BEGINNING stringByAppendingString:formattedMiddle] stringByAppendingString: EDMODO_CONNECT_LOGIN_END];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    
    // load webview
    [_webView loadRequest:requestURL];
    
    // add webview to view stack
    [self addSubview:_webView];
    
    /*
     // create quit button to abort login procedure
     CGFloat buttonSide = self.bounds.size.height * 0.05;
     UIButton *quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
     quitButton.frame = CGRectMake(0.0, 0.0, buttonSide, buttonSide);
     quitButton.showsTouchWhenHighlighted = YES;
     quitButton.backgroundColor = [UIColor clearColor];
     [quitButton setBackgroundImage:[UIImage imageNamed:@"213-reply"] forState:UIControlStateNormal];
     [quitButton addTarget:self action:@selector(quitLogin:) forControlEvents:UIControlEventTouchUpInside];
     
     [self addSubview:quitButton];
     */
    
	UITapGestureRecognizer *tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(quitLogin:)];
	[tapRecognizer setNumberOfTapsRequired:1];
	[tapRecognizer setDelegate:self];
	[self addGestureRecognizer:tapRecognizer];
    
}

-(void) quitLogin:(id)sender
{
    _cancelHandler();
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// function not used curently
// created to test cookies may be used later if login procedure changes
- (void) logCookies {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        NSLog(@" Cookie [%@]", [cookie name]);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (webView.scrollView.contentSize.width > webView.frame.size.width) {
        CGFloat newContentOffsetX = (webView.scrollView.contentSize.width/2) - (webView.bounds.size.width/2);
        [webView.scrollView setContentOffset:CGPointMake(newContentOffsetX, 0)];
    }
    
    // Commented out for later in case we need to use cookies
    //[self logCookies];
    
    // extract data from webview URL
    NSString *fragment = [webView.request.URL fragment];
    
    // check if fragment contains access code
    if ([fragment rangeOfString:@"access_token="].location != NSNotFound) {
        NSArray *fragmentComponents = [fragment componentsSeparatedByString:@"&"];
        
        // find access token component
        for (int i = 0; i < [fragmentComponents count]; i++) {
            
            NSString *component = [fragmentComponents objectAtIndex:i];
            
            if ([component rangeOfString:@"access_token="].location != NSNotFound) {
                NSString *accessToken = [component stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
                if (!accessToken) {
                    // FIXME(dbanks)
                    // Is this an error or a cancel?
                    _cancelHandler();
                } else {
                    _successHandler(accessToken);
                }
            }
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
