//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class ANHPushKitNotificationHub;

@protocol ANHPushKitNotificationHubDelegate <NSObject>

@optional

- (void)notificationHub:(ANHPushKitNotificationHub *)notificationHub didReceiveIncomingPushWithPayload:(NSDictionary *)payload withCompletionHandler:(void (^)(void))completionHandler;

@end
