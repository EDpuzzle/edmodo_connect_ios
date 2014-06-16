//
//  ECBusyViewController.h
//  ProtoComicApp
//
//  Created by Luca Prasso on 2/26/14.
//  Copyright (c) 2014 Luca Prasso Edmodo. All rights reserved.
//

// Global semaphore for whether or not the app is 'busy'.
@interface EMBusyManager : NSObject

+ (id)sharedInstance;

- (id)init;

// When you're doing something asynch, use these.  Increment on start of action,
// decrement on end.
//
// When we transition from not busy to busy, we add a view controller with a spinner to the top
// of the view controller stack.
// When we transition from busy to not busy, we kill that view controller.

- (void)incrementBusyCount;
- (void)decrementBusyCount;
- (BOOL)isBusy;


@end
