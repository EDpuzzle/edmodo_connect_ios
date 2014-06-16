//
//  EMDataStore
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/17/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMBlockTypes.h"

#define ONE_API_GROUP_ID      @"id"
#define ONE_API_GROUP_TITLE       @"title"
#define ONE_API_GROUP_SUBJECT            @"subject"
#define ONE_API_GROUP_URL              @"url"
#define ONE_API_GROUP_OWNERS              @"owners"


#define ONE_API_USER_ID         @"id"
#define ONE_API_USER_FIRST_NAME       @"first_name"
#define ONE_API_USER_LAST_NAME          @"last_name"
#define ONE_API_USER_TITLE             @"user_title"
#define ONE_API_USER_TYPE             @"type"
#define ONE_API_USER_VERIFIED_INSTITUTION_MEMBER  @"verified_institution_member"
#define ONE_API_MEMBERSHIP_USER @"user"
#define ONE_API_MEMBERSHIP_GROUP @"group"


typedef EMArrayResultBlock_t EMStoreArrayResultBlock_t;
typedef EMDictionaryResultBlock_t EMStoreDictionaryResultBlock_t;

@protocol EMDataStore;


/**
 * Object that reads & writes Edmodo data.
 * Maybe works through some version of the API, maybe just reading/writing
 * mock data.
 */
@protocol EMDataStore

// Who is currently logged in?
-(void)getCurrentUser:(EMStoreDictionaryResultBlock_t) successHandler
              onError:(EMNSErrorBlock_t) errorHandler;

// Get information on the given user.  May or may not work depending on user permissions.
-(void)getUser:(NSInteger)edmodoID
     onSuccess:(EMStoreDictionaryResultBlock_t) successHandler
       onError:(EMNSErrorBlock_t) errorHandler;

// Get groups owned by or containing current user.
-(void)getGroupsForCurrentUser:(EMStoreArrayResultBlock_t) successHandler
                       onError:(EMNSErrorBlock_t) errorHandler;

// Get memberships of the given group
-(void)getGroupMemberships:(NSInteger) groupID
                 onSuccess: (EMStoreArrayResultBlock_t) successHandler
                   onError:(EMNSErrorBlock_t) errorHandler;

@end



