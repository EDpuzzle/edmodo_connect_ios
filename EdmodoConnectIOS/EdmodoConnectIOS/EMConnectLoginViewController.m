//
//  EMConnectLoginViewController.m
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/16/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import "EMObjects.h"
#import "EMConnectDataStore.h"
#import "EMConnectLoginViewController.h"

@interface EMConnectLoginViewController ()

@end

@implementation EMConnectLoginViewController {
    UIWebView *_webView;
    NSString* _clientID;
    EMStringResultBlock_t _successHandler;
    EMVoidResultBlock_t _cancelHandler;
    EMNSErrorBlock_t _errorHandler;
}

static NSString* const EDMODO_CONNECT_LOGIN_BEGINNING = @"https://api.edmodo.com/oauth/authorize?";
static NSString* const EDMODO_CONNECT_LOGIN_MIDDLE = @"client_id=%@";
static NSString* const EDMODO_CONNECT_LOGIN_END = @"&redirect_uri=https%3A%2F%2Fapi.edmodo.com%2Fstatus-lb&response_type=token&scope=basic%20read_groups";

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithClientID:(NSString*)clientID
             onSuccess:(EMStringResultBlock_t)successHandler
              onCancel:(EMVoidResultBlock_t)cancelHandler
               onError:(EMNSErrorBlock_t)errorHandler {
    self = [super init];
    if (self) {
        _clientID = clientID;
        _successHandler = successHandler;
        _cancelHandler = cancelHandler;
        _errorHandler = errorHandler;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void) viewDidAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // create UIWebview to fill the screen
    _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
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
    [self.view addSubview:_webView];
    
    // create quit button to abort login procedure
    CGFloat buttonSide = self.view.bounds.size.height * 0.05;
    UIButton *quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    quitButton.frame = CGRectMake(0.0, 0.0, buttonSide, buttonSide);
    quitButton.showsTouchWhenHighlighted = YES;
    quitButton.backgroundColor = [UIColor clearColor];
    [quitButton setBackgroundImage:[UIImage imageNamed:@"213-reply"] forState:UIControlStateNormal];
    [quitButton addTarget:self action:@selector(quitLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:quitButton];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
