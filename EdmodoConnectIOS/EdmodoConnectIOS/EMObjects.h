//
//  EMObjects
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/17/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMBlockTypes.h"
#import "EMUser.h"
#import "EMGroup.h"
#import "EMDataStore.h"

/**
 FIXME(dbanks)
 We should be more thoughtful & thorough with success/error handling.
 */
typedef void (^EMObjectsConfiguredBlock_t)();


/**
 Fetches and stores information relative to currently logged in Edmodo user.
 Convenience functions to fetch information about this user.
 **/
@interface EMObjects: NSObject 

+ (id)sharedInstance;
+ (EMUser*)getCurrentUser;
+ (BOOL)isLoggedIn;

- (id)init;

// When told to reset from data store, where are we pulling from?
- (void) setDataStore:(id<EMDataStore>)dataStore;
// Pull data from Edmodo data store, if we have one.
// If we don't, nothing is loaded and we call success.
// If we do, we do RPCs or whatever to fetch data, success or failure
// is bubbled back up through handlers.
- (void) resetFromDataStore: (EMVoidResultBlock_t)successHandler
                   onError: (EMNSErrorBlock_t)errorHandler;


// utility methods
-(void) clear;

-(void) logStatus;

- (EMGroup*) getGroupByID: (NSString*) groupID;

- (void)getUserByID:(NSString*)userID
          onSuccess: (EMObjectResultBlock_t)successHandler
            onError: (EMNSErrorBlock_t)errorHandler;

/*
// For all groups where:
//   - this app is installed
//   - current user is a member
// Return userToken of group's teacher.
-(NSArray *) getStudentTeachersTokens;
// For all group where:
//   - this app is installed.
//   - current user is a member
// Return the userToken of classmates in the group.
-(NSArray *) getStudentClassmatesTokens;
// User tokens for any user who's a member of a group I manage.
-(NSArray *) getOwnedGroupMemberTokens;
 */

// Ids or actual groups: member and owned.
-(NSArray *) getAllGroups;
-(NSArray *) getAllGroupIDs;

// Ids or actual groups: owned.
-(NSArray *) getOwnedGroups;
-(NSArray *) getOwnedGroupIDs;

// Ids or actual groups: member.
-(NSArray *) getMemberGroups;
-(NSArray *) getMemberGroupIDs;

// Chaperone = person who can control what I see.
// For a teacher, chaperone = just me.
// For a student, chaperone = me + all owners of all groups I belong to.
-(NSArray*) getChaperoneUserIDs;

/*
-(NSArray *) getContainingGroupIDs;


-(NSArray *) getContainingGroups;
*/
/*
-(NSInteger) getUserGroupsCount;
-(NSString *) getUserGroupTitleAtIndex:(NSInteger) index;
-(NSString *) getUserGroupSubjectAtIndex:(NSInteger) index;
-(NSString *) getUserGroupTitleSubjectAtIndex:(NSInteger) index;
-(NSString *) getUserGroupIDAtIndex:(NSInteger) index;
-(NSString *) getUserGroupsIDsAsString;
*/
@end

