//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class MSNotificationHub;
@class MSInstallation;

@protocol MSInstallationEnrichmentDelegate <NSObject>

@optional

/**
 * Method that allows to enrich intercepted installation with any data before it is saved to the backend.
 *
 * @param installation The instance of MSInstallation that the user can make changes to
 */
- (void)notificationHub:(MSNotificationHub *)notificationHub willEnrichInstallation:(MSInstallation *)installation;

@end
