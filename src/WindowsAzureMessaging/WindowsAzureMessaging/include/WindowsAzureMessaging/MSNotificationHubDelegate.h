//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MSNotificationHub;
@class MSNotificationHubMessage;

@protocol MSNotificationHubDelegate <NSObject>

@optional

/**
 * Callback method that will be called whenever a push notification is clicked
 * from notification center or a notification is received in foreground.
 *
 * @param notificationHub The instance of MSNotificationHub
 * @param message The push notification details.
 * @param completionHandler The completion handler which should be called with NoData upon completion.
 */
- (void)notificationHub:(MSNotificationHub *)notificationHub
    didReceivePushNotification:(MSNotificationHubMessage *)message
        fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void)notificationHub:(MSNotificationHub *)notificationHub 
    didReceivedPushToken:(NSString *)pushToken;

- (void)notificationHub:(MSNotificationHub *)notificationHub
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

@end
