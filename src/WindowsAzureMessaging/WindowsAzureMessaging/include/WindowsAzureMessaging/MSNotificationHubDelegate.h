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

/**
 * Callback method that will be called whenever the push token is retrieved.
 *
 * @param notificationHub The instance of MSNotificationHub
 * @param pushToken The push token
 */
- (void)notificationHub:(MSNotificationHub *)notificationHub 
    didReceivePushToken:(NSString *)pushToken NS_SWIFT_NAME(notificationHub(_:pushToken:));

/**
 * Callback method that will be called whenever there is an error in
 * registering for remote notifications.
 *
 * @param notificationHub The instance of MSNotificationHub
 * @param error The error received
 */
- (void)notificationHub:(MSNotificationHub *)notificationHub
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

@end
