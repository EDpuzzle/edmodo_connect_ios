//
//  EMGroup.h
//  EdmodoMobileTestApp
//
//  Created by Luca Prasso on 12/18/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMGroup : NSObject

// Note:
// OneAPI uses integers for ids.
// In wrapper objects we change that to strings.
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) NSArray* ownerUserIDStrings;

-(id) init;
-(id) initFromOneAPIJson: (NSDictionary*) jsonDict;
-(void) logGroup;

@end
  
