//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "ANHPushKitHubOptions.h"

@implementation ANHPushKitHubOptions

- (instancetype)init {
    if ((self = [super init])) {

    }
    
    return self;
}

- (instancetype)initWithDesiredPushTypes:(NSSet<PKPushType> *)pushTypes {
    if ((self = [super init])) {
        _desiredPushTypes = pushTypes;
    }
    
    return self;
}

@end
