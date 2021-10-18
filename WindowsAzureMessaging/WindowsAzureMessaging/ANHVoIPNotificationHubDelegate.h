//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class ANHVoIPNotificationHub;

@protocol ANHVoIPNotificationHubDelegate <NSObject>

@optional

- (void)notificationHub:(ANHVoIPNotificationHub *)notificationHub didReceiveIncomingPushWithPayload:(NSDictionary *)payload withCompletionHandler:(void (^)(void))completionHandler;

@end
