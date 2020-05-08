//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSNotificationHubMessage.h"

@implementation MSNotificationHubMessage

@synthesize title;
@synthesize message;
@synthesize badge;
@synthesize additionalData;

- (instancetype)init {
  if (self = [super init]) {
    additionalData = [NSMutableDictionary new];
  }

  return self;
}

- (instancetype)initWithNotification:(NSDictionary *)notification {
  if (self = [super init]) {
    additionalData = [NSMutableDictionary new];

    for (id key in notification) {
      if ([key isEqual:@"aps"]) {
        NSDictionary *aps = [notification valueForKey:key];
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

+ (instancetype)createFromNotification:(NSDictionary *)notification {
  MSNotificationHubMessage *message = [[MSNotificationHubMessage alloc] initWithNotification:notification];
  return message;
}

@end
