//
//  EMConnectLoginViewController.m
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/16/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <CoreFoundation/CFURL.h>

#import "EMObjects.h"
#import "EMConnectDataStore.h"

#import "EMConnectLoginView.h"

#define EDMODO_COLOR_R 0.93
#define EDMODO_COLOR_G 0.93
#define EDMODO_COLOR_B 0.95
#define EDMODO_COLOR_ALPHA 0.7

@interface EMConnectLoginView ()

@end

@implementation EMConnectLoginView {
    UIWebView *_webView;
    NSString* _clientID;
    NSString* _redirectURI;
    NSArray* _scopes;
    EMStringResultBlock_t _successHandler;
    EMVoidResultBlock_t _cancelHandler;
    EMNSErrorBlock_t _errorHandler;
}

static CGFloat const EC_WebViewHeight = 450;
static CGFloat const EC_WebViewWidth = 400;

static NSString* const EDMODO_CONNECT_LOGIN_BEGINNING = @"https://api.edmodo.com/oauth/authorize?";

- (id)initWithFrame:(CGRect)rect
       withClientID:(NSString*)clientID
    withRedirectURI:(NSString*)redirectURI
         withScopes:(NSArray*)scopes
          onSuccess:(EMStringResultBlock_t)successHandler
           onCancel:(EMVoidResultBlock_t)cancelHandler
            onError:(EMNSErrorBlock_t)errorHandler {
    self = [super initWithFrame:rect];
    if (self) {
        _clientID = clientID;
        _redirectURI = redirectURI;
        _scopes = scopes;
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

- (NSString *) __urlEscapeString:(NSString*)string
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (__bridge CFStringRef) string,
                                                                                 NULL,
                                                                                 CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                                                                 kCFStringEncodingUTF8));
}


- (void)viewDidLoad {
    
    //the more the delay the errors will be less so within 0.1-0.3 would be fine
    
}

-(void)loadURL:(id)sender{
    [_webView stopLoading]; //added this line to stop the previous request
    NSString* scopesString = [_scopes componentsJoinedByString:@" "];
    
    NSDictionary* params = [[NSDictionary alloc] initWithObjects: @[
                                                                    _clientID,
                                                                    @"token",
                                                                    scopesString,
                                                                    _redirectURI,
                                                                    ]
                                                         forKeys: @[
                                                                    @"client_id",
                                                                    @"response_type",
                                                                    @"scope",
                                                                    @"redirect_uri",
                                                                    ]];
    
    
    NSString* fullURL = [EDMODO_CONNECT_LOGIN_BEGINNING stringByAppendingString:[self __createUrlParamsString:params]];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestURL];
}

- (NSString*) __createUrlParamsString:(NSDictionary*)params
{
    NSMutableString* str = [NSMutableString stringWithString:@""];
    
    BOOL first = YES;
    for (NSString *key in [params allKeys]) {
        NSString *escapedValue = [self __urlEscapeString:[params objectForKey:key]];
        if (!first) {
            [str appendString:@"&"];
        }
        first = NO;
        
        [str appendString:key];
        [str appendString:@"="];
        [str appendString:escapedValue];
    }
    return [NSString stringWithString:str];
}

- (void) __createWidgets
{
    self.backgroundColor = [UIColor colorWithRed:EDMODO_COLOR_R green:EDMODO_COLOR_G blue:EDMODO_COLOR_B alpha:EDMODO_COLOR_ALPHA];
    
    // create UIWebview at some nice size, centered.
    // Caller can overload if they want.
    CGFloat x = (self.frame.size.width - EC_WebViewWidth)/2;
    // Scoot it up above center to make room for keyboard
    CGFloat y = (self.frame.size.height - EC_WebViewHeight)/5;
    CGRect wvFrame = CGRectMake(x, y, EC_WebViewWidth, EC_WebViewHeight);
    
    _webView = [[UIWebView alloc]initWithFrame:wvFrame];
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.scrollView.scrollEnabled = NO;
    
    // load preview html while the real content is loading because it's very slow
    [_webView loadHTMLString:@"<html><head><style>h1{text-align:center;font-family:'Helvetica Neue';font-size:40px;}.outer {display: table; position: absolute;height: 100%;width: 100%;}.middle {display: table-cell;vertical-align: middle;}.inner {margin-left: auto;margin-right: auto;width:600px;}</style><body><div class='outer'><div class='middle'><div class='inner'><h1>Loading Edmodo Login...</h1></div></div></div></body></html>" baseURL:nil];
    [self performSelector:@selector(loadURL:) withObject:nil afterDelay:0.2];
    
    // add webview to view stack
    [self addSubview:_webView];
    
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
