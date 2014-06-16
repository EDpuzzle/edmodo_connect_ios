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

/**
 Handles login/logout of Edmodo User, including UI/UX componments.
 Populates EMObjects
 */
@interface EMLoginService : NSObject<UIAlertViewDelegate>

+ (id)sharedInstance;

/**
 Clear out currently logged in user.
 Remove any cached authentication tokens.
 */
-(void) logout;

/**
 Offer widgets to login.
 Get user 'key' so we can talk to datastore as some authenticated user.
 Use that key to fill in EMObjects with the right data.
 
 Anywhere along the way we might get cancelled or find an error.
 */
-(void) initiateLogin:(UIViewController*)parentViewController
         withClientID:(NSString*)clientID
            onSuccess:(EMVoidResultBlock_t)successHandler
             onCancel:(EMVoidResultBlock_t)cancelHandler
              onError:(EMNSErrorBlock_t)errorHandler;

/**
 Pull user 'key' out of local storage.
 
 If we find it, return YES immediately.
 Try to use that key to get data from Edmodo, fill in EMObjects.
 Call back success/fail/error as appropriate.
 
 If we don't find it, return NO.  None of the callbacks will be used.
 */
-(BOOL) restoreLogin:(EMVoidResultBlock_t)successHandler
             onCancel:(EMVoidResultBlock_t)cancelHandler
              onError:(EMNSErrorBlock_t)errorHandler;


@end
