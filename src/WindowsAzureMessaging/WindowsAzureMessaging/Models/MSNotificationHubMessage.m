// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSNotificationHubMessage.h"

@implementation MSNotificationHubMessage

@synthesize title;
@synthesize message;
@synthesize badge;
@synthesize additionalData;

- (instancetype)init {
    self = [super init];
    
    return self;
}

- (instancetype)initWithNotification:(NSDictionary *)notification {
    if ((self = [super init])) {
        for (id key in notification) {
            if([key isEqual: @"aps"]) {
                NSDictionary *aps = [notification valueForKey:@"aps"];
                NSObject *alertObject = [aps valueForKey:@"alert"];
                if (alertObject != nil) {
                    if ([alertObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *alertDict = (NSDictionary *)alertObject;
                        title = [alertDict valueForKey:@"title"];
                        message = [alertObject valueForKey:@"body"];
                    } else if ([alertObject isKindOfClass:[NSString class]]) {
                        message = (NSString *)alertObject;
                    } else {
                        NSLog(@"Unable to parse notification content. Unexpected format: %@", alertObject);
                    }
                }
                badge = [[aps valueForKey:@"badge"] integerValue];
            } else {
                [additionalData setObject:[notification valueForKey:key] forKey:key];
            }
        }
    }
    
    return self;
}

+ (MSNotificationHubMessage *)createFromNotification:(NSDictionary *)notification
{
    MSNotificationHubMessage *message = [[MSNotificationHubMessage alloc] initWithNotification:notification];
    return message;
}

@end
