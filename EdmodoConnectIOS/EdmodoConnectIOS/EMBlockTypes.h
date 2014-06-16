//
//  EMBlockTypes
//  EdmodoTestMobile
//
//  Created by Luca Prasso on 12/17/13.
//  Copyright (c) 2013 Luca Prasso Edmodo. All rights reserved.
//


// Generic block (callback) types.

// Passes back a string.
typedef void (^EMStringResultBlock_t)(NSString *);
// Passes back an array.
typedef void (^EMArrayResultBlock_t)(NSArray *);
// Passes back a dictionary.
typedef void (^EMDictionaryResultBlock_t)(NSDictionary *);
// Passes back generic object.
typedef void (^EMObjectResultBlock_t)(NSObject *);
// Passes back BOOL.
typedef void (^EMBoolResultBlock_t)(BOOL);
// Passes back NSInteger.
typedef void (^EMIntegerResultBlock_t)(NSInteger);
// Passes back nothing.
typedef void (^EMVoidResultBlock_t)();
// Passes back standard error.
typedef void (^EMNSErrorBlock_t)(NSError *);
