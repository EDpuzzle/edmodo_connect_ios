//
//  ECBusyViewController.m
//  ProtoComicApp
//
//  Created by Luca Prasso on 2/26/14.
//  Copyright (c) 2014 Luca Prasso Edmodo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EMBusyManager.h"

#define SPINNER_VIEW_Z_INDEX 100

@implementation EMBusyManager {
    NSInteger _busyCount;
    UIActivityIndicatorView* spinner;
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
        _busyCount = 0;
        [self __setupSpinner];
    }
    return self;
}

-(void)__setupSpinner {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat centerX = MIN(screenRect.size.width, screenRect.size.height) * 0.5;
    CGFloat centerY= MAX(screenRect.size.width, screenRect.size.height) * 0.5;
    
    spinner = [[UIActivityIndicatorView alloc]
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.frame = screenRect;
    spinner.center = CGPointMake(centerX, centerY);
    spinner.hidesWhenStopped = YES;
    spinner.color = [UIColor blackColor];
    spinner.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.5];
    
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:spinner];
    // Always on top.
    spinner.layer.zPosition = MAXFLOAT;
}

- (void)incrementBusyCount {
    _busyCount += 1;
    if (_busyCount == 1) {
        [spinner startAnimating];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
}

- (void)decrementBusyCount {
    NSInteger oldBusyCount = _busyCount;
    _busyCount -= 1;
    if (_busyCount < 0)
    {
        _busyCount = 0;
    }
    if (oldBusyCount == 1) {
        [spinner stopAnimating];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

- (BOOL)isBusy {
    return (_busyCount > 0);
}

@end
