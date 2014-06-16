//
//  EMConnectDataStore.m
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/17/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import "EMErrorHelper.h"
#import "EMConnectDataStore.h"

static NSString* const EDMODO_CONNECT_LOGOUT = @"https://api.edmodo.com/logout";

static NSString* const EDMODO_CONNECT_CURRENT_USER = @"https://api.edmodo.com/users/me?access_token=%@";
static NSString* const EDMODO_CONNECT_USER = @"https://api.edmodo.com/users/%ld?access_token=%@";
static NSString* const EDMODO_CONNECT_CURRENT_USER_GROUPS = @"https://api.edmodo.com/groups?access_token=%@";
static NSString* const EDMODO_CONNECT_CURRENT_USER_MEMBERSHIPS = @"https://api.edmodo.com/group_memberships?access_token=%@&group_id=%li";


@implementation EMConnectDataStore
{
    NSString* accessToken;
    // FIXME(dbanks)
    // The access token fixes the notion of the current user.
    // In principle that's all this object should need, the access token.
    // In reality, we have to do some post-processing of API calls that may required the
    // current user id.
    // So when we change accessToken we clear this out and when we fetch access token
    // we fill it in.
    // If some other call requires this and we don't have it set, throw an error.
    // Pretty safe bet that the first thing you do on getting your access token is fetch info
    // on current user so it should not be a problem.
    NSString* currentUserId;
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
        accessToken = nil;
        currentUserId = nil;
    }
    return self;
}


-(void) setAccessToken: (NSString*)at
{
    accessToken = at;
    currentUserId = nil;
    
    // if accessToken is nil, we're logged out.
    // Somehow EC still thinks we are logged in, we need to explicitly tell them we're not.
    if (at == nil) {
        NSURL *url = [NSURL URLWithString:[EDMODO_CONNECT_LOGOUT stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        NSURLResponse * response = nil;
        NSError * error = nil;
        
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    }
}

-(void)getCurrentUser:(EMStoreDictionaryResultBlock_t) successHandler
              onError:(EMNSErrorBlock_t) errorHandler
{
    // No access token, error.
    if (accessToken == nil) {
        [EMErrorHelper callErrorHandler:errorHandler
                            withMessage:@"No access token"];
        return;
    }
    
    NSString *urlAsString = [NSString stringWithFormat:EDMODO_CONNECT_CURRENT_USER, accessToken];
    NSURL *url = [NSURL URLWithString:[urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    __typeof(self) __block blockSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [blockSelf handleCurrentUserRequestResponse:response
                                                                  withData:data
                                                                  andError:error
                                                       usingSuccessHandler:successHandler
                                                           andErrorHandler:errorHandler];
                           }];
}


-(void)getUser:(NSInteger)edmodoID
     onSuccess:(EMStoreDictionaryResultBlock_t) successHandler
       onError:(EMNSErrorBlock_t) errorHandler {
    // No access token, error.
    if (accessToken == nil) {
        [EMErrorHelper callErrorHandler:errorHandler
                            withMessage:@"No access token"];
        return;
    }
    
    NSString *urlAsString = [NSString stringWithFormat:EDMODO_CONNECT_USER, (long)edmodoID, accessToken];
    NSURL *url = [NSURL URLWithString:[urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    __typeof(self) __block blockSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [blockSelf handleUserRequestResponse:response
                                                           withData:data
                                                           andError:error
                                                usingSuccessHandler:successHandler
                                                    andErrorHandler:errorHandler];
                           }];
    
    
    
}

-(void)getGroupsForCurrentUser:(EMStoreArrayResultBlock_t)successHandler
                       onError:(EMNSErrorBlock_t)errorHandler
{
    // No access token, error.
    if (accessToken == nil) {
        [EMErrorHelper callErrorHandler:errorHandler
                            withMessage:@"No access token"];
        return;
    }
    
    // Get all groups this user can see.
    NSString *urlAsString = [NSString stringWithFormat:EDMODO_CONNECT_CURRENT_USER_GROUPS, accessToken];
    NSURL *url = [NSURL URLWithString:[urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    __typeof(self) __block blockSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [blockSelf handleGroupsRequestResponse:response
                                                             withData:data
                                                             andError:error
                                                  usingSuccessHandler:successHandler
                                                      andErrorHandler:errorHandler];
                           }];
}

// Get memberships for given group.
-(void)getGroupMemberships:(NSInteger) groupID
                 onSuccess: (EMStoreArrayResultBlock_t) successHandler
                   onError:(EMNSErrorBlock_t) errorHandler
{
    // No access token, error.
    if (accessToken == nil) {
        [EMErrorHelper callErrorHandler:errorHandler
                            withMessage:@"No access token"];
        return;
    }
    
    // Get all group memberships for the groups.
    NSString *urlAsString = [NSString stringWithFormat:EDMODO_CONNECT_CURRENT_USER_MEMBERSHIPS,
                             accessToken,
                             (long)groupID];
    NSURL *url = [NSURL URLWithString:[urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    
    __typeof(self) __block blockSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [blockSelf handleGroupMembersRequestResponse:response
                                                                   withData:data
                                                                   andError:error
                                                        usingSuccessHandler:successHandler
                                                            andErrorHandler:errorHandler];
                           }];
    
}

-(void)handleCurrentUserRequestResponse:(NSURLResponse *)response
                               withData:(NSData *)data
                               andError:(NSError *)error
                    usingSuccessHandler:(EMStoreDictionaryResultBlock_t)successHandler
                        andErrorHandler:(EMNSErrorBlock_t)errorHandler
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    
    if (error) {
        NSLog(@"API FAILED");
        errorHandler(error);
    } else {
        // if we got a valid reponse code from the request we can parse the data
        if (httpResponse.statusCode == 200) {
            
            NSError* jsonError;
            NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:&jsonError];
            
            if (jsonError != nil) {
                NSLog(@"Error: %@", jsonError);
            }
            successHandler(jsonDict);
        } else {
            NSLog(@"FAILED");
            [EMErrorHelper callErrorHandler:errorHandler
                                withMessage:[NSString stringWithFormat:@"Get current user failed with http error code %ld",
                                             (long)httpResponse.statusCode]];
        }
    }
}

-(void)handleUserRequestResponse:(NSURLResponse *)response
                        withData:(NSData *)data
                        andError:(NSError *)error
             usingSuccessHandler:(EMStoreDictionaryResultBlock_t)successHandler
                 andErrorHandler:(EMNSErrorBlock_t)errorHandler
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    
    if (error) {
        NSLog(@"API FAILED");
        errorHandler(error);
    } else {
        // if we got a valid reponse code from the request we can parse the data
        if (httpResponse.statusCode == 200) {
            
            NSError* jsonError;
            NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingAllowFragments
                                                                       error:&jsonError];
            
            if (jsonError != nil) {
                NSLog(@"Error: %@", jsonError);
            }
            successHandler(jsonDict);
        } else {
            NSLog(@"FAILED");
            [EMErrorHelper callErrorHandler:errorHandler
                                withMessage:[NSString stringWithFormat:@"Get user failed with http error code %ld",
                                             (long)httpResponse.statusCode]];
        }
    }
}

-(void)handleGroupsRequestResponse:(NSURLResponse *)response
                          withData:(NSData *)data
                          andError:(NSError *)error
               usingSuccessHandler:(EMStoreArrayResultBlock_t)successHandler
                   andErrorHandler:(EMNSErrorBlock_t)errorHandler
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    
    if (error) {
        NSLog(@"API FAILED");
        errorHandler(error);
    } else {
        // if we got a valid reponse code from the request we can parse the data
        if (httpResponse.statusCode == 200) {
            
            NSError* jsonError;
            NSArray* jsonArray = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&jsonError];
            
            if (jsonError != nil) {
                NSLog(@"Error: %@", jsonError);
            }
            successHandler(jsonArray);
        } else {
            NSLog(@"FAILED");
            [EMErrorHelper callErrorHandler:errorHandler
                                withMessage:[NSString stringWithFormat:@"Get groups failed with http error code %ld",
                                             (long)httpResponse.statusCode]];
        }
    }
}


-(void)handleGroupMembersRequestResponse:(NSURLResponse *)response
                                withData:(NSData *)data
                                andError:(NSError *)error
                     usingSuccessHandler:(EMStoreArrayResultBlock_t)successHandler
                         andErrorHandler:(EMNSErrorBlock_t)errorHandler
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    
    if (error) {
        NSLog(@"API FAILED");
        errorHandler(error);
    } else {
        // if we got a valid reponse code from the request we can parse the data
        if (httpResponse.statusCode == 200) {
            
            NSError* jsonError;
            NSArray* jsonArray = [NSJSONSerialization
                                  JSONObjectWithData:data
                                  options:NSJSONReadingAllowFragments
                                  error:&jsonError];
            
            if (jsonError != nil) {
                NSLog(@"Error: %@", jsonError);
            }
            // We have an array of group memberships responses.
            successHandler(jsonArray);
            
        } else {
            NSLog(@"FAILED");
            [EMErrorHelper callErrorHandler:errorHandler
                                withMessage:[NSString stringWithFormat:@"Get groups failed with http error code %ld",
                                             (long)httpResponse.statusCode]];
        }
    }
}

@end
