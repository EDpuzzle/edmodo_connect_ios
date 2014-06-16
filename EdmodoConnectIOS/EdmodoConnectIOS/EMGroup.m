//
//  EMGroup.m
//  EdmodoMobileTestApp
//
//  Created by Luca Prasso on 12/18/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import "EMUser.h"
#import "EMGroup.h"
#import "EMDataStore.h"

@implementation EMGroup

@synthesize title = _title;
@synthesize subject = _subject;
@synthesize groupID = _groupID;
@synthesize ownerUserIDStrings = _ownerUserIDStrings;
@synthesize url = _url;

-(id) init {
    
    self = [super init];
    
    if (self) {
        _title = nil;
        _subject = nil;
        _groupID = nil;
        _url = nil;
        _ownerUserIDStrings = nil;
    }
    
    return self;
}

-(id) initFromOneAPIJson: jsonDict {
    
    self = [super init];
    
    if (self) {
        _title = (NSString*) [jsonDict valueForKey:ONE_API_GROUP_TITLE];
        _subject = (NSString*) [jsonDict valueForKey:ONE_API_GROUP_SUBJECT];
        _groupID = [[jsonDict valueForKey:ONE_API_GROUP_ID] stringValue];
        NSArray* userJsonArray = (NSArray *)[jsonDict objectForKey:ONE_API_GROUP_OWNERS];
        NSMutableArray* tmpIds = [[NSMutableArray alloc] init];
        for (NSDictionary* userJson in userJsonArray) {
            [tmpIds addObject:[[userJson objectForKey:ONE_API_USER_ID] stringValue]];
        }
        _ownerUserIDStrings = tmpIds;
    }
    
    return self;
}


-(void) logGroup
{
    NSLog(@" group    [%@] [%li]", _title, (long)_groupID);
    NSLog(@" subject  [%@]", _subject);
    NSLog(@" url      [%@]", _url);
}

@end
