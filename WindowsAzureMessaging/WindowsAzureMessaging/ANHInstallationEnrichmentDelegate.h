//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class ANHService;
@class ANHInstallation;

/**
 * A protocol for enriching an installation before it is sent to the backend.
 */
@protocol ANHInstallationEnrichmentDelegate <NSObject>

@optional

/**
 * Method that allows to enrich intercepted installation with any data before it is saved to the backend.
 *
 * @param notificationHub The NotificationHub instance.
 * @param installation The instance of Installation that the user can make changes to
 */
- (void)notificationHub:(__kindof ANHService *)notificationHub willEnrichInstallation:(ANHInstallation *)installation;

@end
