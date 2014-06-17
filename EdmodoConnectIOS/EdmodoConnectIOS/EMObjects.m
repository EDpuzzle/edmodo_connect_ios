//
//  EMObjects
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/17/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import "EMObjects.h"
#import "EMUser.h"
#import "EMGroup.h"

@implementation EMObjects

{
    EMUser *currentUser;
    
    NSMutableSet *allGroupIDs;
    NSMutableArray *allGroups;
    
    NSMutableSet *ownedGroupIDs;
    NSMutableArray *ownedGroups;
    
    NSMutableSet *memberGroupIDs;
    NSMutableArray *memberGroups;
    
    NSMutableSet *teacherUserIDs;
    NSMutableSet *classmateUserIDs;
    NSMutableSet *studentUserIDs;
    
    NSMutableDictionary* usersByUserID;
    NSMutableDictionary* offLimitsUsersByUserID;
    
    id <EMDataStore> _dataStore;
}

+(id)sharedInstance {
    static dispatch_once_t once_token = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&once_token, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

+(EMUser*)getCurrentUser {
    EMObjects* emo = [self sharedInstance];
    return emo->currentUser;
}

+ (BOOL)isLoggedIn {
    return ([self getCurrentUser] != nil);
}


- (id)init {
    self =[super init];
    if (self) {
        [self clear];
    }
    return self;
}

- (void) setDataStore:(id<EMDataStore>)dataStore {
    _dataStore = dataStore;
}


- (EMGroup*) getGroupByID: (NSString*) groupID
{
    for (EMGroup* group in allGroups) {
        if ([group.groupID isEqualToString:groupID]) {
            return group;
        }
    }
    return nil;
}


-(void) clear
{
    _dataStore = nil;
    
    currentUser = nil;
    
    studentUserIDs = [NSMutableSet new];
    classmateUserIDs = [NSMutableSet new];
    teacherUserIDs = [NSMutableSet new];
    
    allGroupIDs = [NSMutableSet new];
    allGroups = [NSMutableArray new];
    
    ownedGroupIDs = [NSMutableSet new];
    ownedGroups = [NSMutableArray new];
    
    memberGroupIDs = [NSMutableSet new];
    memberGroups = [NSMutableArray new];
    
    usersByUserID = [NSMutableDictionary new];
    offLimitsUsersByUserID = [NSMutableDictionary new];
    
}

-(BOOL) isTeacher
{
    return (currentUser &&
            [currentUser.type  isEqual: EDMODO_USER_TYPE_TEACHER]);
}

-(BOOL) isStudent
{
    return (currentUser &&
            [currentUser.type  isEqual: EDMODO_USER_TYPE_STUDENT]);
}

-(void) resetFromDataStore: (EMVoidResultBlock_t)successHandler
                   onError: (EMNSErrorBlock_t)errorHandler
{
    currentUser = nil;
    
    [studentUserIDs removeAllObjects];
    [classmateUserIDs removeAllObjects];
    [teacherUserIDs removeAllObjects];
    
    [allGroupIDs removeAllObjects];
    [allGroups removeAllObjects];
    
    [ownedGroupIDs removeAllObjects];
    [ownedGroups removeAllObjects];
    
    [memberGroupIDs removeAllObjects];
    [memberGroups removeAllObjects];
    
    if (_dataStore == nil) {
        // We refreshed, there's no data store so we're empty.
        successHandler();
    }
    
    __typeof(self) __block blockSelf = self;
    [self __getCurrentUser: ^() {
        [blockSelf __getGroups: ^() {
            [blockSelf __getAllGroupMembers:successHandler
                                    onError:errorHandler];
        }  onError: errorHandler];
    }  onError:errorHandler];
}

-(void) __getCurrentUser:(EMVoidResultBlock_t)successHandler
                 onError:(EMNSErrorBlock_t)errorHandler
{
    __typeof(self) __block blockSelf = self;
    [_dataStore getCurrentUser:^(NSDictionary* userDictionary) {
        blockSelf->currentUser = [[EMUser alloc] initFromOneAPIJson:userDictionary];
        NSString* key = blockSelf->currentUser.userID;
        [blockSelf->usersByUserID setObject:blockSelf->currentUser
                                     forKey:key];
        successHandler();
    } onError: ^(NSError *error) {
        errorHandler(error);
    }];
}

-(void) __getGroups: (EMVoidResultBlock_t)successHandler
            onError: (EMNSErrorBlock_t)errorHandler
{
    // Get all his groups.
    __typeof(self) __block blockSelf = self;
    [_dataStore getGroupsForCurrentUser:^(NSArray* groupsArray) {
        NSString* currentUserID = blockSelf->currentUser.userID;
        
        NSDictionary* groupJson;
        for (groupJson in groupsArray) {
            EMGroup * group = [[EMGroup alloc] initFromOneAPIJson:groupJson];
            
            [blockSelf->allGroupIDs addObject: [[groupJson objectForKey:ONE_API_GROUP_ID] stringValue]];
            [blockSelf->allGroups addObject:group];
            
            if ([group.ownerUserIDStrings containsObject:  currentUserID]) {
                [blockSelf->ownedGroups addObject: group];
                [blockSelf->ownedGroupIDs addObject: group.groupID];
            } else {
                [blockSelf->memberGroups addObject: group];
                [blockSelf->memberGroupIDs addObject: group.groupID];
                
                // If I am a member of this group, all the owners are my teachers.
                for (NSString* ownerID in group.ownerUserIDStrings) {
                    [blockSelf->teacherUserIDs addObject: ownerID];
                }
            }
        }
        successHandler();
    } onError:^(NSError * error) {
        errorHandler(error);
    }];
}

/**
 Fire off a bunch of queries, one for each group, to get memberships.
 File results away in arrays of classmates or students, as appropriate.
 
 When they all have finished call success iff there were no errors.
 
 FIXME(dbanks)
 One API allows you to send batch requests, use that.
 */
-(void) __getAllGroupMembers: (EMVoidResultBlock_t)successHandler
                     onError: (EMNSErrorBlock_t)errorHandler
{
    __typeof(self) __block blockSelf = self;
    
    NSInteger __block totalCount = [allGroups count];
    NSInteger __block errorCount = 0;
    NSError * __block lastError = nil;
    
    // After each response, check to see if all queries have finished.
    // If so, call success or failure.
    void (^maybeFinalHandler)(EMVoidResultBlock_t successHandler,
                              EMNSErrorBlock_t errorHandler);
    maybeFinalHandler = ^(EMVoidResultBlock_t successHandler,
                          EMNSErrorBlock_t errorHandler) {
        if (totalCount > 0) {
            return;
        }
        if (errorCount > 0) {
            errorHandler(lastError);
            return;
        }
        successHandler();
    };
    
    // Maybe we have no groups.
    if (totalCount == 0) {
        successHandler();
        return;
    }
    
    // Get members of all owned groups.
    for (EMGroup* group in ownedGroups) {
        [_dataStore getGroupMemberships:[group.groupID integerValue]
                             onSuccess:^(NSArray *memberships) {
                                 // These are members of groups I own.
                                 totalCount -= 1;
                                 for (NSDictionary* membership in memberships) {
                                     NSDictionary* user = [membership objectForKey: ONE_API_MEMBERSHIP_USER];
                                     [blockSelf->studentUserIDs addObject: [[user objectForKey:ONE_API_USER_ID] stringValue]];
                                 }
                                 maybeFinalHandler(successHandler, errorHandler);
                             } onError:^(NSError* error) {
                                 totalCount -=1;
                                 errorCount += 1;
                                 lastError = error;
                                 maybeFinalHandler(successHandler, errorHandler);
                             }];
    }
    
    // Get members of all member groups.
    for (EMGroup* group in memberGroups) {
        [_dataStore getGroupMemberships:[group.groupID integerValue]
                             onSuccess:^(NSArray *memberships) {
                                 // These are members of groups I am in.
                                 totalCount -= 1;
                                 for (NSDictionary* membership in memberships) {
                                     NSDictionary* user = [membership objectForKey: ONE_API_MEMBERSHIP_USER];
                                     [blockSelf->classmateUserIDs addObject: [[user objectForKey:ONE_API_USER_ID] stringValue]];
                                 }
                                 maybeFinalHandler(successHandler, errorHandler);
                             } onError:^(NSError* error) {
                                 totalCount -=1;
                                 errorCount += 1;
                                 lastError = error;
                                 maybeFinalHandler(successHandler, errorHandler);
                             }];
    }
}

- (void)getUserByID:(NSString*)userID
          onSuccess: (EMObjectResultBlock_t)successHandler
            onError: (EMNSErrorBlock_t)errorHandler
{
    // I may already have this user cached.
    EMUser* user = [usersByUserID objectForKey:userID];
    if (user) {
        successHandler(user);
        return;
    }
    // I may have tried before to get this user and heard that he is not and will never be
    // available b/c we are not in the same group.
    if ([offLimitsUsersByUserID objectForKey:userID]) {
        NSError* error = [[NSError alloc] initWithDomain:@"Edmodo"
                                                    code:401
                                                userInfo:nil];
        errorHandler(error);
        return;
    }
    
    __typeof(self) __block blockSelf = self;
    [_dataStore getUser:[userID integerValue]
             onSuccess:^(NSDictionary* userDictionary) {
                 EMUser* user = [[EMUser alloc] initFromOneAPIJson:userDictionary];
                 [blockSelf->usersByUserID setObject:user
                                              forKey:userID];
                 successHandler(user);
             } onError: ^(NSError *error) {
                 // FIXME(dbanks)
                 // Depending on the error, we may never be able to get this user b/c we're not allowed
                 // to see him (he's in a different class).
                 // Remember that fact.
                 [blockSelf->offLimitsUsersByUserID setObject:@(1) forKey:userID];
                 errorHandler(error);
             }];
    
}


-(NSArray *)getAllGroupIDs
{
    return [allGroupIDs allObjects];
}

-(NSArray *)getAllGroups
{
    return allGroups;
}

-(NSArray *) getOwnedGroupIDs
{
    return [ownedGroupIDs allObjects];
}

-(NSArray *) getOwnedGroups
{
    return ownedGroups;
}

-(NSArray *) getMemberGroupIDs
{
    return [memberGroupIDs allObjects];
}

-(NSArray *) getMemberGroups
{
    return memberGroups;
}

-(NSArray*) getChaperoneUserIDs
{
    NSMutableArray* retVal = [[NSMutableArray alloc] init];
    if (!currentUser) {
        return retVal;
    }
    
    // I can always tell myself what to do.
    [retVal addObject: currentUser.userID];
    
    // If I'm a teacher, that's it.  No one else is the boss of me.
    if ([self isTeacher]) {
        return retVal;
    }
    
    NSMutableSet* ownerIDSet = [[NSMutableSet alloc] init];
    for (EMGroup* group in memberGroups) {
        NSArray* ownerIDStrings = [group ownerUserIDStrings];
        [ownerIDSet addObjectsFromArray:ownerIDStrings];
    }
    [retVal addObjectsFromArray:[ownerIDSet allObjects]];
    return retVal;
}


#pragma mark - Support

-(void) logStatus
{
    [currentUser logUser];
    NSLog(@"Edmodo Manager: memberGroups         [%lu]", (unsigned long)[memberGroups count]);
    NSLog(@"Edmodo Manager: classmateTokens     [%lu]", (unsigned long)[classmateUserIDs count]);
    NSLog(@"Edmodo Manager: teacherTokens       [%lu]", (unsigned long)[teacherUserIDs count]);
    
    NSLog(@"Edmodo Manager: ownedGroups         [%lu]", (unsigned long)[ownedGroups count]);
    NSLog(@"Edmodo Manager: studentTokens         [%lu]", (unsigned long)[studentUserIDs count]);
}

@end
