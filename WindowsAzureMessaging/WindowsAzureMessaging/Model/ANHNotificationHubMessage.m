//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHNotificationHubMessage.h"

@implementation ANHNotificationHubMessage

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    if ((self = [super init]) != nil) {
        _userInfo = userInfo;

        NSDictionary *aps = [userInfo valueForKey:@"aps"];
        NSObject *alertObject = [aps valueForKey:@"alert"];
        if (alertObject != nil) {
            if ([alertObject isKindOfClass:[NSDictionary class]]) {
                _title = [alertObject valueForKey:@"title"];
                _body = [alertObject valueForKey:@"body"];
            } else if ([alertObject isKindOfClass:[NSString class]]) {
                _title = nil;
                _body = (NSString *)alertObject;
            } else {
                _title = nil;
                _body = nil;
            }
        }
        
        NSObject *badgeObject = [aps valueForKey:@"badge"];
        if (badgeObject != nil && [badgeObject isKindOfClass:[NSNumber class]]) {
            _badge = (NSNumber *)badgeObject;
        }
        
        NSObject *contentAvailableObject = [aps valueForKey:@"content-available"];
        if (contentAvailableObject != nil && [contentAvailableObject isKindOfClass:[NSNumber class]]) {
            _contentAvailable = (NSNumber *)contentAvailableObject;
        }
    }

    return self;
}

@end
