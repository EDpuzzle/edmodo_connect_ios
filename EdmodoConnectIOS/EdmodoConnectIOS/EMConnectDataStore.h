//
//  EMConnectDataStore.h
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/17/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMUser.h"
#import "EMGroup.h"
#import "EMDataStore.h"

@interface EMConnectDataStore: NSObject <EMDataStore>
{
}

+ (id)sharedInstance;

- (id)init;

// Setup.
// Before you can call any of the methods here, configure with an access token.
// Getting, remembering, revoking the access token is not handled by this
// object.
-(void) setAccessToken: (NSString*) accessToken;

@end

