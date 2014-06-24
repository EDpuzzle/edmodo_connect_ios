//
//  EMMockLoginViewController.h
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/16/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMDataStore.h"
#import "EMMockDataStore.h"

// Login to mock instance of Edmodo.
// Present user with pre-set collection of users, they select one, login
// as that User.
@interface EMMockLoginView : UIView

- (id)initWithFrame:(CGRect)rect
          onSuccess:(EMIntegerResultBlock_t)successHandler
           onCancel:(EMVoidResultBlock_t)cancelHandler
            onError:(EMNSErrorBlock_t)errorHandler;

@end
