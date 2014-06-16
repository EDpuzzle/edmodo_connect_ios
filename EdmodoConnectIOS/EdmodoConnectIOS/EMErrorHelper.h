//
//  EMErrorHelper.h
//  ProtoComicApp
//
//  Created by Doug Banks on 5/9/14.
//  Copyright (c) 2014 Luca Prasso Edmodo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EMBlockTypes.h"


@interface EMErrorHelper : NSObject

// Wrapper function: make an NSError with given string and custom domain.
+(void) callErrorHandler:(EMNSErrorBlock_t) errorHandler
             withMessage:(NSString*) errorMessage;

+(NSError *) makeErrorWithMessage:(NSString *)errorMessage;

@end
