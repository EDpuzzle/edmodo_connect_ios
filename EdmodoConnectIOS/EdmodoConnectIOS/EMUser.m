//
//  EMUser.m
//  EdmodoMobileTestApp
//
//  Created by Luca Prasso on 12/17/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import "EMDataStore.h"
#import "EMUser.h"

@implementation EMUser {
    BOOL _isVerified;
}

@synthesize userID = _userID;
@synthesize type = _type;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize avatarURL = _avatarURL;
@synthesize thumbURL = _thumbURL;
@synthesize title = _title;
@synthesize timeZone = _timeZone;
@synthesize url = _url;

-(id) init {
    
    self = [super init];
    
    if (self) {
        _userID = nil;
        _type = nil;
        _firstName = nil;
        _lastName = nil;
        _avatarURL = nil;
        _thumbURL = nil;
        _title = nil;
        _timeZone = nil;
        _url = nil;
        _isVerified = NO;
    }
    
    return self;
}


-(id) initFromOneAPIJson: (NSDictionary*) jsonDict
{
    self = [super init];
    if (self) {
        self.userID     = [[jsonDict valueForKey:ONE_API_USER_ID] stringValue];
        self.firstName  = [jsonDict valueForKey:ONE_API_USER_FIRST_NAME];
        self.lastName   = [jsonDict valueForKey:ONE_API_USER_LAST_NAME];
        self.title      = [jsonDict valueForKey:ONE_API_USER_TITLE];
        self.type       = [jsonDict valueForKey:ONE_API_USER_TYPE];
        id tmpValue     = [jsonDict valueForKey:ONE_API_USER_VERIFIED_INSTITUTION_MEMBER];
        if (tmpValue) {
            _isVerified = [tmpValue boolValue];
        } else {
            _isVerified = NO;
        }
    }
    return self;
}

-(BOOL) isVerified
{
    return _isVerified;
}

-(BOOL) isTeacher
{
    BOOL returnStatus = NO;
    
    if ([_type isEqualToString:EDMODO_USER_TYPE_TEACHER]) returnStatus = YES;
    
    return returnStatus;
}

-(BOOL) isStudent
{
    BOOL returnStatus = NO;
    
    if ([_type isEqualToString:EDMODO_USER_TYPE_STUDENT]) returnStatus = YES;
    
    return returnStatus;
}

-(NSString*)getFullName
{
    if (!_lastName) {
        if (!_firstName) {
            return @"<unknown>";
        }
        return _firstName;
    } else {
        if (!_firstName) {
            return _lastName;
        } else {
            return [NSString stringWithFormat:@"%@ %@",
                    _firstName,
                    _lastName];
        }
    }
}

-(NSString*) getNonPIIName
{
    if (!_firstName) {
        if (!_lastName) {
            // Make something up.
            return @"Q. Q.";
        }
        return [NSString stringWithFormat:@"%@.",
                [_lastName substringWithRange:NSMakeRange(0, 1)]];
    } else {
        if (!_lastName) {
            return [NSString stringWithFormat:@"%@.",
                   [_firstName substringWithRange:NSMakeRange(0, 1)]];
        } else {
            return [NSString stringWithFormat:@"%@. %@.",
                    [_firstName substringWithRange:NSMakeRange(0, 1)],
                    [_lastName substringWithRange:NSMakeRange(0, 1)]];
            
        }
    }
}

-(void) logUser
{
    NSLog(@" user     [%@ %@ %@]", _title, _firstName, _lastName);
    NSLog(@" type     [%@]", _type);
    NSLog(@" id    [%li]", (long)_userID);
    NSLog(@" avatar   [%@]", _avatarURL);
    NSLog(@" thumb    [%@]", _thumbURL);
    NSLog(@" TimeZone [%@]", _timeZone);
    NSLog(@" URL      [%@]", _url);
}

@end
