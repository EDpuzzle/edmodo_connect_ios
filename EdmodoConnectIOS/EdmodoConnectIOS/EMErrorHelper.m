//
//  EMErrorHelper.m
//  ProtoComicApp
//
//  Created by Doug Banks on 5/9/14.
//  Copyright (c) 2014 Luca Prasso Edmodo. All rights reserved.
//

#import "EMBlockTypes.h"
#import "EMErrorHelper.h"

@implementation EMErrorHelper


#define EM_CUSTOM_ERROR_DOMAIN  @"EdmodoCustomError"
#define EM_CUSTOM_ERROR_CODE    19720304

+(NSError *) makeErrorWithMessage:(NSString *)errorMessage
{
    NSMutableDictionary* d = [[NSMutableDictionary alloc] init];
    [d setObject:errorMessage forKey:NSLocalizedDescriptionKey];
    NSError* error = [NSError errorWithDomain:EM_CUSTOM_ERROR_DOMAIN
                                         code:EM_CUSTOM_ERROR_CODE
                                     userInfo:d];
    return error;
}

+(void) callErrorHandler:(EMNSErrorBlock_t) errorHandler
             withMessage:(NSString*) errorMessage {
    if (errorHandler != nil) {
        NSError* error = [self makeErrorWithMessage:errorMessage];
        errorHandler(error);
    }
}

@end
