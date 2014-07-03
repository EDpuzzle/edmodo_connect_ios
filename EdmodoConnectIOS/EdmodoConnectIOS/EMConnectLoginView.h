//
//  EMConnectLoginViewController
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/16/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMDataStore.h"
#import "EMConnectDataStore.h"
#import "EMMockDataStore.h"

// web view controller to connect to Edmodo Connect
// and allow Edmodo user login
//

@interface EMConnectLoginView : UIView  <UIWebViewDelegate,
UIGestureRecognizerDelegate>

- (id)initWithFrame:(CGRect)rect
       withClientID:(NSString*)clientID
    withRedirectURI:(NSString*)redirectURI
         withScopes:(NSArray*)scopes
          onSuccess:(EMStringResultBlock_t)successHandler
           onCancel:(EMVoidResultBlock_t)cancelHandler
            onError:(EMNSErrorBlock_t)errorHandler;

- (void) setWebViewFrame:(CGRect)rect;

@end
