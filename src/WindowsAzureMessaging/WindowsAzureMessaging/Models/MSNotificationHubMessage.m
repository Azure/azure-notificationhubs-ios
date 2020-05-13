//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSNotificationHubMessage.h"

@implementation MSNotificationHubMessage

@synthesize title;
@synthesize body;
@synthesize badge;
@synthesize data;

- (instancetype)initWithNotification:(NSDictionary *)notification {
    if (self = [super init]) {
        NSMutableDictionary *messageData = [NSMutableDictionary new];

        for (id key in notification) {
            if ([key isEqual:@"aps"]) {
                NSDictionary *aps = [notification valueForKey:key];
                NSObject *alertObject = [aps valueForKey:@"alert"];
                if (alertObject != nil) {
                    if ([alertObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *alertDict = (NSDictionary *)alertObject;
                        title = [alertDict valueForKey:@"title"];
                        body = [alertObject valueForKey:@"body"];
                    } else if ([alertObject isKindOfClass:[NSString class]]) {
                        body = (NSString *)alertObject;
                    } else {
                        NSLog(@"Unable to parse notification content. Unexpected format: %@", alertObject);
                    }
                }
                badge = [[aps valueForKey:@"badge"] integerValue];
            } else {
                [messageData setObject:[notification valueForKey:key] forKey:key];
            }
        }
        
        data = [NSDictionary dictionaryWithDictionary:messageData];
    }

    return self;
}

+ (instancetype)createFromNotification:(NSDictionary *)notification {
    MSNotificationHubMessage *message = [[MSNotificationHubMessage alloc] initWithNotification:notification];
    return message;
}

@end
