//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class MSNotificationHub;
@class MSInstallation;

@protocol MSInstallationLifecycleDelegate <NSObject>

@optional

- (void)notificationHub:(MSNotificationHub *)notificationHub didSaveInstallation:(MSInstallation *)installation;

- (void)notificationHub:(MSNotificationHub *)notificationHub
    didFailToSaveInstallation:(MSInstallation *)installation
                    withError:(NSError *)error;

@end
