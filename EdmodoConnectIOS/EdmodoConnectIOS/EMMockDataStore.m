//
//  EMMockDataStore.m
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/17/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import "EMMockDataStore.h"
#import "EMUser.h"
#import "EMErrorHelper.h"

@implementation EMMockDataStore
{
    NSInteger currentUserID;
    NSMutableDictionary* mockUsersByUserID;
    NSMutableDictionary* mockGroupsByGroupID;
    NSMutableDictionary* mockGroupMembershipsByUserID;
    NSMutableDictionary* mockGroupMembershipsByGroupID;
    
    NSMutableDictionary* mockGroupsOwnedByOwnerID;
}

+(id)sharedInstance {
    
    static dispatch_once_t once_token = 0;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&once_token, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init {
    self =[super init];
    if (self) {
        mockUsersByUserID = [[NSMutableDictionary alloc] init];
        mockGroupsByGroupID = [[NSMutableDictionary alloc] init];
        mockGroupMembershipsByUserID = [[NSMutableDictionary alloc] init];
        mockGroupMembershipsByGroupID = [[NSMutableDictionary alloc] init];
        mockGroupsOwnedByOwnerID = [[NSMutableDictionary alloc] init];
        
        currentUserID = 0;
    }
    return self;
}

-(void) populate
{
    [mockUsersByUserID removeAllObjects];
    [mockGroupsByGroupID removeAllObjects];
    [mockGroupMembershipsByUserID removeAllObjects];
    [mockGroupMembershipsByGroupID removeAllObjects];
    [mockGroupsOwnedByOwnerID removeAllObjects];
    
    [self __addVerifiedMockUser:EDMODO_USER_TYPE_TEACHER:@"Tom":@"McTeacher":21000];
    [self __addVerifiedMockUser:EDMODO_USER_TYPE_TEACHER:@"Bob":@"VonTeacher":21001];
    [self __addVerifiedMockUser:EDMODO_USER_TYPE_TEACHER:@"Jane":@"O'Teacher":21002];
    [self __addMockUser:EDMODO_USER_TYPE_TEACHER:@"Sneaky":@"Teacherson":21003:NO];
    
    [self __addVerifiedMockUser:EDMODO_USER_TYPE_STUDENT:@"Scott":@"Prudent":33000];
    [self __addVerifiedMockUser:EDMODO_USER_TYPE_STUDENT:@"Chuck":@"Mild":33001];
    [self __addVerifiedMockUser:EDMODO_USER_TYPE_STUDENT:@"Brad":@"Joy":33002];
    [self __addVerifiedMockUser:EDMODO_USER_TYPE_STUDENT:@"Gabby":@"Whirl":33003];
    
    [self __addVerifiedMockUser:EDMODO_USER_TYPE_STUDENT:@"Cindy":@"Scarf":33004];
    [self __addVerifiedMockUser:EDMODO_USER_TYPE_STUDENT:@"Doug":@"Blog":33005];
    [self __addVerifiedMockUser:EDMODO_USER_TYPE_STUDENT:@"Larry":@"Lion":33006];

    [self __addVerifiedMockUser:EDMODO_USER_TYPE_STUDENT:@"Evil":@"DiNasty":33007];

    // Note: for this to work, you must create all mock users before creating groups.
    
    // Tom teaches one class:
    //   Scott
    //   Chuck
    [self __addMockGroup:10002
                        :@"Tom's Science Class"
                        :@"Science"
                        :21000
                        :@[@33000, @33001]];
    
    // Tom teaches a different class:
    //   Scott
    //   Chuck
    [self __addMockGroup:10012
                        :@"Tom's Art Class"
                        :@"Art"
                        :21000
                        :@[@33000, @33001]];
    
    // Bob teaches:
    //   Chuck
    //   Brad
    //   Gabby
    [self __addMockGroup:10003
                        :@"Bob Class"
                        :@"Math"
                        :21001
                        :@[@33001, @33002, @33003]];
    
    // Jane teaches:
    //   Cindy
    //   Doug
    //   Larry
    [self __addMockGroup:10004
                        :@"Jane Class"
                        :@"English"
                        :21002
                        :@[@33004, @33005, @33006]];
    
    // Sneaky teaches:
    //   Larry
    //   Evil
    [self __addMockGroup:10005
                        :@"Rotten Class"
                        :@"Cruelty"
                        :21003
                        :@[@33006, @33007]];
}

- (void) __addVerifiedMockUser:(NSString*) userType
                              :(NSString*) firstName
                              :(NSString*) lastName
                              :(NSInteger) userID
{
    [self __addMockUser:userType
                       :firstName
                       :lastName
                       :userID
                       :YES];
}


- (void) __addMockUser:(NSString*) userType
                      :(NSString*) firstName
                      :(NSString*) lastName
                      :(NSInteger) userID
                      :(BOOL) verified
{
    NSMutableDictionary* tmp =
    [NSMutableDictionary dictionaryWithDictionary: @{
                                                     ONE_API_USER_TYPE : userType,
                                                     ONE_API_USER_FIRST_NAME : firstName,
                                                     ONE_API_USER_LAST_NAME : lastName,
                                                     ONE_API_USER_ID : @(userID),
                                                     }];
    if ([userType isEqual: EDMODO_USER_TYPE_TEACHER]) {
        [tmp setObject:@(verified) forKey:ONE_API_USER_VERIFIED_INSTITUTION_MEMBER];
    }
    [mockUsersByUserID setObject: [NSDictionary dictionaryWithDictionary:tmp]
                          forKey: @(userID)];
}

-(NSDictionary *) getUserWithId:(NSInteger) userID
{
    NSDictionary * user = [mockUsersByUserID objectForKey: @(userID)];
    NSAssert1(user, @"User with id %ld is missing.", (long)userID);
    return user;
}


- (NSArray*)getAllMockUsers
{
    return [mockUsersByUserID allValues];
}

- (NSArray*)getMockTeachers
{
    NSArray* allUsers = [mockUsersByUserID allValues];
    NSMutableArray* returnValue = [[NSMutableArray alloc] init];
    for (NSDictionary* user in allUsers) {
        if ([[user valueForKey:@"type"]  isEqual: EDMODO_USER_TYPE_TEACHER]) {
            [returnValue addObject:user];
        }
    }
    // FIXME(dbanks)
    // return [returnValue copy];
    // Do this all over the place.
    return returnValue;
}

- (NSArray*)getMockStudents
{
    NSArray* allUsers = [mockUsersByUserID allValues];
    NSMutableArray* returnValue = [[NSMutableArray alloc] init];
    for (NSDictionary* user in allUsers) {
        if ([[user valueForKey:@"type"]  isEqual: EDMODO_USER_TYPE_STUDENT]) {
            [returnValue addObject:user];
        }
    }
    return returnValue;
}


- (NSDictionary *)getSafeUser:(NSInteger)userID
{
    NSDictionary * user = [mockUsersByUserID objectForKey: @(userID)];
    NSAssert1(user, @"User with id %ld is missing.", (long)userID);
    return user;
}

- (void) __addMockGroup:(NSInteger) groupID
                       :(NSString*) title
                       :(NSString*) subject
                       :(NSInteger) ownerID
                       :(NSArray*) memberIDs
{
    NSMutableArray *owners = [[NSMutableArray alloc] init];
    NSDictionary * ownerDict = [self getSafeUser:ownerID];
    [owners addObject:ownerDict];
    
    NSDictionary *groupDict = @{
                                ONE_API_GROUP_TITLE : title,
                                ONE_API_GROUP_ID : @(groupID),
                                ONE_API_GROUP_SUBJECT : subject,
                                ONE_API_GROUP_OWNERS : owners,
                                };
    
    [mockGroupsByGroupID setObject: groupDict forKey: @(groupID)];
    
    appendToArrayInDictionary(mockGroupsOwnedByOwnerID, @(ownerID), groupDict);
    
    
    // Create membership dictionary.
    for (NSNumber* userID in memberIDs) {
        NSDictionary * userDict = [self getSafeUser:[userID integerValue]];
        
        NSMutableDictionary* membership = [[NSMutableDictionary alloc] init];
        [membership setObject: userDict forKey:ONE_API_MEMBERSHIP_USER];
        [membership setObject: groupDict forKey:ONE_API_MEMBERSHIP_GROUP];
        // Store it both ways.
        appendToArrayInDictionary(mockGroupMembershipsByGroupID,
                                  @(groupID),
                                  membership);
        appendToArrayInDictionary(mockGroupMembershipsByUserID,
                                  userID,
                                  membership);
        
    }
}

- (void) setCurrentUser: (NSInteger) userID
{
    currentUserID = userID;
}

-(void)getCurrentUser:(EMStoreDictionaryResultBlock_t) successHandler
              onError:(EMNSErrorBlock_t) errorHandler
{
    // Fake async.
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    __typeof(self) __block blockSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        [blockSelf __getCurrentUser:successHandler
                            onError:errorHandler];
        
    });
}

// Get information on the given user.
// May or may not work depending on user permissions.
// Make this truly async so we can test calling code properly.
-(void)getUser:(NSInteger)edmodoID
     onSuccess:(EMStoreDictionaryResultBlock_t) successHandler
       onError:(EMNSErrorBlock_t) errorHandler
{
    // Fake async.
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    __typeof(self) __block blockSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        [blockSelf __getUser:edmodoID
                   onSuccess:successHandler
                     onError:errorHandler];
        
    });
}


-(void)getGroupsForCurrentUser:(EMStoreArrayResultBlock_t)successHandler
                       onError:(EMNSErrorBlock_t)errorHandler
{
    // Fake async.
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    __typeof(self) __block blockSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        [blockSelf __getGroupsForCurrentUser:successHandler
                                     onError:errorHandler];
    });
}

// Get members of the given group, array of 'membership' objects.
-(void)getGroupMemberships:(NSInteger) groupID
                 onSuccess: (EMStoreArrayResultBlock_t) successHandler
                   onError:(EMNSErrorBlock_t) errorHandler
{
    // Fake async.
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    __typeof(self) __block blockSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        [blockSelf __getGroupMemberships:groupID
                               onSuccess:successHandler
                                 onError:errorHandler];
    });
}



-(void)__getCurrentUser:(EMStoreDictionaryResultBlock_t) successHandler
                onError:(EMNSErrorBlock_t) errorHandler
{
    // If there is no current user, we should not be asking this question.
    if (currentUserID == 0) {
        [EMErrorHelper callErrorHandler:errorHandler
                            withMessage:@"No current user"];
        return;
    }
    NSDictionary * userDict = [self getSafeUser:currentUserID];
    
    if (userDict == nil) {
        [EMErrorHelper callErrorHandler:errorHandler
                            withMessage:@"Bad current user id"];
        return;
    }
    successHandler(userDict);
}

-(void)__getUser:(NSInteger)edmodoID
       onSuccess:(EMStoreDictionaryResultBlock_t) successHandler
         onError:(EMNSErrorBlock_t) errorHandler
{
    // Does the current user have the rights to see this user?
    if (![self __currentUserCanSeeOtherUser:edmodoID]) {
        NSError* error = [[NSError alloc] initWithDomain:@"Edmodo"
                                                    code:401
                                                userInfo:nil];
        errorHandler(error);
        return;
    }
    // Find the user.
    successHandler([mockUsersByUserID objectForKey:@(edmodoID)]);
}

-(BOOL)__currentUserCanSeeOtherUser:(NSInteger)edmodoID
{
    if ([self __anyGroupContains:edmodoID
                             and:currentUserID]) {
        return YES;
    }
    
    if ([self __anyGroupOwnedBy:edmodoID
                       contains:currentUserID]) {
        return YES;
    }
    
    if ([self __anyGroupOwnedBy:currentUserID
                       contains:edmodoID]) {
        return YES;
    }
    return NO;
}

-(NSArray*) __getOwnerIDsFromMembership: (NSDictionary*)membership
{
    NSMutableArray* retVal = [NSMutableArray array];
    NSDictionary* groupDict = [membership objectForKey:ONE_API_MEMBERSHIP_GROUP];
    if (!groupDict) {
        return @[];
    }
    NSArray* owners = [groupDict objectForKey:ONE_API_GROUP_OWNERS];
    for (NSDictionary* owner in owners) {
        [retVal addObject:[owner objectForKey:ONE_API_USER_ID]];
    }
    return retVal;
};

-(BOOL) __anyGroupOwnedBy:(NSInteger)ownerID
                 contains:(NSInteger)memberID
{
    NSArray* memberships = [mockGroupMembershipsByUserID objectForKey: @(memberID)];
    if (!memberships) {
        return NO;
    }
    for (NSDictionary* membership in memberships) {
        NSArray* groupOwnerIDs = [self __getOwnerIDsFromMembership:membership];
        for (NSNumber* groupOwnerID in groupOwnerIDs) {
            if ([groupOwnerID integerValue] == ownerID) {
                return YES;
            }
        }
    }
    return NO;
}


-(BOOL) __anyGroupContains:(NSInteger)edmodoID1
                       and:(NSInteger)edmodoID2
{
    NSArray* memberships1 = [mockGroupMembershipsByUserID objectForKey: @(edmodoID1)];
    NSArray* memberships2 = [mockGroupMembershipsByUserID objectForKey: @(edmodoID2)];
    
    if (!memberships1 || !memberships2) {
        return NO;
    }
    
    for (NSDictionary* membership1 in memberships1) {
        NSDictionary* group1 = [membership1 objectForKey:ONE_API_MEMBERSHIP_GROUP];
        NSInteger group1ID = [[group1 objectForKey:ONE_API_GROUP_ID] integerValue];
        
        for (NSDictionary*  membership2 in memberships2) {
            NSDictionary* group2 = [membership2 objectForKey:ONE_API_MEMBERSHIP_GROUP];
            NSInteger group2ID = [[group2 objectForKey:ONE_API_GROUP_ID] integerValue];
            if (group2ID == group1ID) {
                return YES;
            }
        }
    }
    return NO;
}


-(void)__getGroupsForCurrentUser:(EMStoreArrayResultBlock_t)successHandler
                         onError:(EMNSErrorBlock_t)errorHandler
{
    // If there is no current user, we should not be asking this question.
    if (currentUserID == 0) {
        [EMErrorHelper callErrorHandler:errorHandler
                            withMessage:@"No current user"];
        return;
    }
    
    NSMutableArray* retval = [[NSMutableArray alloc] init];
    NSArray* memberships = [mockGroupMembershipsByUserID objectForKey:@(currentUserID)];
    
    for (NSDictionary* membershipDict in memberships) {
        [retval addObject: [membershipDict objectForKey:ONE_API_MEMBERSHIP_GROUP]];
    }
    
    NSArray* ownedGroups = [mockGroupsOwnedByOwnerID objectForKey:@(currentUserID)];
    if (ownedGroups) {
        [retval addObjectsFromArray:ownedGroups];
    }
    
    // Find all groups of which this guy is a member or owner.
    successHandler(retval);
}

// Get members of the given group, array of 'membership' objects.
-(void)__getGroupMemberships:(NSInteger) groupID
                   onSuccess: (EMStoreArrayResultBlock_t) successHandler
                     onError:(EMNSErrorBlock_t) errorHandler
{
    NSArray* memberships = [mockGroupMembershipsByGroupID objectForKey: @(groupID)];
    if (!memberships) {
        [EMErrorHelper callErrorHandler:errorHandler
                            withMessage:@"Bad Group ID"];
    }
    successHandler(memberships);
}


void appendToArrayInDictionary(NSMutableDictionary* dict,
                               id<NSCopying> key,
                               NSObject* value) {
    NSMutableArray* currentValue = [dict objectForKey: key];
    if (currentValue == nil) {
        currentValue = [[NSMutableArray alloc] init];
        [dict setObject: currentValue forKey:key];
    }
    [currentValue addObject: value];
};


#pragma mark - User Core
#pragma mark - User

@end
