//
//  EMUser.h
//  EdmodoMobileTestApp
//
//  Created by Luca Prasso on 12/17/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMUser : NSObject

#define EDMODO_USER_TYPE_TEACHER @"teacher"
#define EDMODO_USER_TYPE_STUDENT @"student"

// Note:
// OneAPI uses integers for ids.
// In wrapper objects we change that to strings.
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *avatarURL;
@property (nonatomic, strong) NSString *thumbURL;
@property (nonatomic, strong) NSString *timeZone;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *email;

-(id) init;
-(id) initFromOneAPIJson: (NSDictionary*) jsonDict;
-(void) logUser;
-(BOOL) isTeacher;
-(BOOL) isStudent;
-(BOOL) isVerified;
-(NSString *) getFullName;
// A version of the name that is not considered Personally
// Identifiable Information.  Still arguing over when that's first name
// or initials or what.
-(NSString *) getNonPIIName;


@end
