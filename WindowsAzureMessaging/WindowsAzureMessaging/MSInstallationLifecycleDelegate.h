//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class MSNotificationHub;
@class MSInstallation;

/**
 * Protocol for the installation lifecycle management for saving an installation calling back when saved successfully or failed to save.
 */
@protocol MSInstallationLifecycleDelegate <NSObject>

@optional

/**
 * The installation saved operation succeeded.
 * @param notificationHub The notification hub instance.
 * @param installation The installation saved to the backend.
 */
- (void)notificationHub:(MSNotificationHub *)notificationHub didSaveInstallation:(MSInstallation *)installation;

/**
 * The installation save operation failed.
 * @param notificationHub The notification hub instance.
 * @param error The error that occurred saving the installation.
 */
- (void)notificationHub:(MSNotificationHub *)notificationHub
    didFailToSaveInstallation:(MSInstallation *)installation
                    withError:(NSError *)error;

@end
