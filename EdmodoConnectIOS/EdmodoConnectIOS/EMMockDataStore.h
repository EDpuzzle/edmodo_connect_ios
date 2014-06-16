//
//  EMMockDataStore.h
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/17/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMDataStore.h"


@interface EMMockDataStore: NSObject <EMDataStore>

+ (id)sharedInstance;
- (id)init;

// setup the mock entities and relationships.
// FIXME(dbanks)
// For now they are hard-coded.  Later could be data-driven.
-(void) populate;

// Manually set who the current user is.
// Provides frame of reference for all the other calls.
- (void) setCurrentUser: (NSInteger) userID;

-(NSArray*) getAllMockUsers;

-(NSArray*) getMockTeachers;
-(NSArray*) getMockStudents;

-(NSDictionary*) getUserWithId:(NSInteger) userId;

@end

