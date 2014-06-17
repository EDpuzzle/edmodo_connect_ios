//
//  EMLoginService.m
//  ProtoComicApp
//
//  Created by Doug Banks on 5/9/14.
//  Copyright (c) 2014 Luca Prasso Edmodo. All rights reserved.
//

#import "EMLoginService.h"
#import "EMObjects.h"
#import "EMMockDataStore.h"
#import "EMConnectDataStore.h"
#import "EMMockLoginViewController.h"
#import "EMConnectLoginViewController.h"

#define LOGIN_TYPE_KEY    @"em__loginType"
#define EDMODO_TOKEN_KEY  @"em__edmodoToken"
#define MOCK_TOKEN_KEY    @"em__mockToken"

#define LOGIN_TYPE_EDMODO   @"LOGIN_TYPE_EDMODO"
#define LOGIN_TYPE_MOCK     @"LOGIN_TYPE_MOCK"

@implementation EMLoginService {
    UIViewController* parentViewController;
    NSString* _clientID;
    EMVoidResultBlock_t successHandler;
    EMVoidResultBlock_t cancelHandler;
    EMNSErrorBlock_t errorHandler;
}

+ (id)sharedInstance
{
    static dispatch_once_t once_token = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&once_token, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

-(void) logout
{
    // Clear out edmodo objects.
    [[EMObjects sharedInstance] clear];
    // Clear out any/all data stores.
    [[EMMockDataStore sharedInstance] setCurrentUser: 0];
    [[EMConnectDataStore sharedInstance] setAccessToken: nil];
    // Clear out cached login info.
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:LOGIN_TYPE_KEY];
    [defaults removeObjectForKey:EDMODO_TOKEN_KEY];
    [defaults removeObjectForKey:MOCK_TOKEN_KEY];
    [defaults synchronize];
}

- (BOOL) restoreLogin:(EMVoidResultBlock_t)sHandler
             onCancel:(EMVoidResultBlock_t)cHandler
              onError:(EMNSErrorBlock_t)eHandler
{
    successHandler = sHandler;
    cancelHandler = cHandler;
    errorHandler = eHandler;
    
    [[EMMockDataStore sharedInstance] populate];
    id<EMDataStore> dataStore =  [self __getCachedDataStore];
    if (dataStore) {
        [self __onDataStoreConfigSuccess:dataStore];
        return YES;
    }
    return NO;
}

-(void) initiateLogin:(UIViewController*)pvc
         withClientID:(NSString*)clientID
            onSuccess:(EMVoidResultBlock_t)sHandler
             onCancel:(EMVoidResultBlock_t)cHandler
              onError:(EMNSErrorBlock_t)eHandler
{
    parentViewController = pvc;
    _clientID = clientID;
    successHandler = sHandler;
    cancelHandler = cHandler;
    errorHandler = eHandler;
    
    [[EMMockDataStore sharedInstance] populate];
    // FIXME(dbanks)
    // We don't really want this log-term, we will always use real login.
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Login"
                                                        message:@"Login with real Edmodo or mock Edmodo?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Real", @"Mock", nil];
    [alertView show];
}

/**
 The user has opted to do a mock login and use the mock data store.
 Provide controls to confirm their user ID.
 We will be called back with a confirmed ID, or some fail/cancel.
 */
- (void) __offerMockLogin {
    [[EMObjects sharedInstance] clear];
    EMMockDataStore* dataStore = [EMMockDataStore sharedInstance];
    
    __typeof(self) __block blockSelf = self;
    EMMockLoginViewController *loginVC = [[EMMockLoginViewController alloc]
                                          init:^(NSInteger userID) {
                                              // Store this key.
                                              [blockSelf __storeLoginData:@(userID)
                                                                   ofType:LOGIN_TYPE_MOCK];
                                              
                                              [dataStore setCurrentUser:userID];
                                              [blockSelf __onDataStoreConfigSuccess: dataStore];
                                          }
                                          onCancel:^() {
                                              [blockSelf __onDataStoreConfigCancel];
                                          }
                                          onError:^(NSError* error) {
                                              [blockSelf __onDataStoreConfigError:error];
                                          }];
    [parentViewController presentViewController:loginVC animated:YES completion:nil];
}

/**
 The user has opted to do a real login using Edmodo connect.
 Provide controls to confirm user ID.
 We will be called back with a confirmed ID, or some fail/cancel.
 */
- (void) __offerRealLogin {
    [[EMObjects sharedInstance] clear];
    __typeof(self) __block blockSelf = self;
    EMConnectLoginViewController *loginVC = [[EMConnectLoginViewController alloc]
                                             initWithClientID:_clientID
                                             onSuccess:^(NSString* accessToken) {
                                                 // Store this key.
                                                 [blockSelf __storeLoginData:accessToken
                                                                      ofType:LOGIN_TYPE_EDMODO];
                                                 
                                                 // Configure the data store with this information.
                                                 EMConnectDataStore* dataStore = [EMConnectDataStore sharedInstance];
                                                 [dataStore setAccessToken:accessToken];
                                                 
                                                 [blockSelf __onDataStoreConfigSuccess: dataStore];
                                             }
                                             onCancel:^() {
                                                 [blockSelf __onDataStoreConfigCancel];
                                             }
                                             onError:^(NSError* error) {
                                                 [blockSelf __onDataStoreConfigError:error];
                                             }];
    
    [parentViewController presentViewController:loginVC animated:YES completion:nil];
}

/**
 The user has configured a data store with some key identifying himself.
 Now we can use the data store to populate our EM Objects with all the 
 people and groups we care about.
 */
-(void) __onDataStoreConfigSuccess: (id<EMDataStore>) dataStore
{
    [parentViewController dismissViewControllerAnimated:YES completion:nil];
    __typeof(self) __block blockSelf = self;
    [[EMObjects sharedInstance] resetFromDataStore:dataStore
                                         onSuccess:^{
                                             blockSelf->successHandler();
                                             [blockSelf __cleanUp];
                                         } onError:^(NSError* nse){
                                             blockSelf->errorHandler(nse);
                                             [blockSelf __cleanUp];
                                         }];
    
}

/**
 When offered a chance to identify himself (either as mock or real Edmodo user), the app
 user said 'forget it'.  Back out.
 */
-(void) __onDataStoreConfigCancel
{
    [parentViewController dismissViewControllerAnimated:YES completion:nil];
    [[EMObjects sharedInstance] clear];
    cancelHandler();
    [self __cleanUp];
}

/**
 When trying to get a valid user id to configued the data store, we got some kind 
 of error.  Just pass it up.
 */
-(void) __onDataStoreConfigError:(NSError*) error
{
    [parentViewController dismissViewControllerAnimated:YES completion:nil];
    [[EMObjects sharedInstance] clear];
    errorHandler(error);
    [self __cleanUp];
}


-(void) __cleanUp {
    parentViewController = nil;
    _clientID = nil;
    successHandler = nil;
    cancelHandler = nil;
    errorHandler = nil;
}

-(id<EMDataStore>) __getCachedDataStore {
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];

    NSString* loginType = (NSString*)[defaults objectForKey:LOGIN_TYPE_KEY];
    if (loginType == nil) {
        return nil;
    }
    
    if ([loginType isEqualToString:LOGIN_TYPE_MOCK]) {
        NSInteger userID = [[defaults objectForKey:MOCK_TOKEN_KEY] integerValue];
        if (userID == 0) {
            return nil;
        }
        [[EMMockDataStore sharedInstance] setCurrentUser:userID];
        return [EMMockDataStore sharedInstance];
    } else {
        NSString* accessToken = (NSString*)[defaults objectForKey: EDMODO_TOKEN_KEY];
        if (accessToken == nil) {
            return nil;
        }
        // FIXME(dbanks)
        // Is the access token still valid?
        // We may reject it b/c we know it's too old, or we try it and it times out.
        [[EMConnectDataStore sharedInstance] setAccessToken:accessToken];
        return [EMConnectDataStore sharedInstance];
    }
}


- (void) __storeLoginData:(id) credentialKey
                  ofType:(NSString*) loginDataType
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:loginDataType forKey:LOGIN_TYPE_KEY];
    if ([loginDataType isEqualToString:LOGIN_TYPE_EDMODO]) {
        [defaults setObject:credentialKey forKey:EDMODO_TOKEN_KEY];        
    } else {
        [defaults setObject:credentialKey forKey:MOCK_TOKEN_KEY];
        
    }
    [defaults synchronize];
}
#pragma mark UIAlertViewDelegate implementation
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [self __offerRealLogin];
            break;
        case 2:
            [self __offerMockLogin];
            break;
    }
}

- (void) alertViewCancel:(UIAlertView*)alertView {
    [self __cleanUp];
}

@end

