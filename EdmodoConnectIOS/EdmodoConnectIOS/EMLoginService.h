//
//  EMLoginService.h
//  ProtoComicApp
//
//  Created by Doug Banks on 5/9/14.
//  Copyright (c) 2014 Luca Prasso Edmodo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIAlertView.h>
#import "EMDataStore.h"

// Valid 'scope' values.
#define EM_BASIC_SCOPE              @"basic"
#define EM_READ_GROUPS_SCOPE        @"read_groups"
#define EM_READ_USER_EMAIL_SCOPE    @"read_user_email"
#define EM_READ_CONNECTIONS_SCOPE   @"read_connections"


//Environments
#define EDMODO_PROD_ENV 1
#define EDMODO_DEV_ENV 0

/**
 Handles login/logout of Edmodo User, including UI/UX componments.
 If user logs in properly, we configure EMObjects shared instance with
 authentication info.
 */
@interface EMLoginService : NSObject<UIAlertViewDelegate>

+ (id)sharedInstance;

/**
 Clear out currently logged in user.
 Clear OMObjects of data store and all loaded data.
 Clear stored keys in local storage (restoreLogin won't do anything).
 */
-(void) logout;

/**
 This function enables or disables the development mode
 in this library.
 **/
-(void) setDevelopmentMode:(BOOL)isDev;

/**
 Offer widgets to login.
 Get user 'key' so we can talk to datastore as some authenticated user.
 Use key to create an empty data store and configure OM Objects with that
 data store.
 
 Anywhere along the way we might get cancelled or find an error.
 */
-(void) initiateLoginInParentView:(UIView*)parentView
                     withClientID:(NSString*)clientID
                  withRedirectURI:(NSString*)redirectURI
                       withScopes:(NSArray*)scopes
                        onSuccess:(EMVoidResultBlock_t)successHandler
                         onCancel:(EMVoidResultBlock_t)cancelHandler
                          onError:(EMNSErrorBlock_t)errorHandler;

/**
 Try to pull user 'key' out of local storage.
 If present, use key to create an empty data store and configure OM Objects with that
 data store, return YES;
 */
-(BOOL) restoreLogin;


@end
