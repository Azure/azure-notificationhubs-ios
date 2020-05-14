//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSNotificationHubMessage.h"

@implementation MSNotificationHubMessage

- (NSString *)getTitle {
    return _title;
}

- (NSString *)getBody {
    return _body;
}

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    if (self = [super init]) {
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
                NSLog(@"Unable to extract alert content. Unexpected class for the alert value: %@", NSStringFromClass(alertObject.class));
                _title = nil;
                _body = nil;
            }
        }
    }

    return self;
}

@end
