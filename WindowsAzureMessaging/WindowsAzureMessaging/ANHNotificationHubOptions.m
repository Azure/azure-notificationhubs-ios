//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHNotificationHubOptions.h"

@implementation ANHNotificationHubOptions

- (instancetype)init {
    if ((self = [super init])) {
        if (@available(iOS 10.0, tvOS 10.0, watchOS 3.0, macOS 10.14, macCatalyst 13.0, *)) {
            _authorizationOptions = (UNAuthorizationOptions)(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge);
        }
    }
    
    return self;
}

- (instancetype)initWithAuthorizationOptions:(UNAuthorizationOptions)authorizationOptions API_AVAILABLE(ios(10.0), watchos(3.0), macos(10.14), macCatalyst(13.0)) {
    if ((self = [super init])) {
        _authorizationOptions = authorizationOptions;
    }
    
    return self;
}

+ (instancetype)optionsWithAuthorizationOptions:(UNAuthorizationOptions)authorizationOptions API_AVAILABLE(ios(10.0), watchos(3.0), macos(10.14), macCatalyst(13.0)) {
    ANHNotificationHubOptions *options = [[ANHNotificationHubOptions alloc] initWithAuthorizationOptions:authorizationOptions];
    return options;
}

@end