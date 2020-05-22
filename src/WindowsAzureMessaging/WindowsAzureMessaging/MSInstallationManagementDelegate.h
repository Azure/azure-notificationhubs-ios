//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class MSNotificationHub;
@class MSInstallation;

@protocol MSInstallationManagementDelegate <NSObject>

@optional

/**
 *Method that allows to save installation to custom back end
 *
 * @param installation The instance of MSInstallation that user can save
 */
- (void)notificationHub:(MSNotificationHub *)notificationHub
    willUpsertInstallation:(MSInstallation *)installation
     withCompletionHandler:(void (^)(BOOL))completionHandler;

/**
 Method that allows to delete installation from custom backend
 *
 @param installationId The id of installation to delete from custom back end
 */
- (void)notificationHub:(MSNotificationHub *)notificationHub willDeleteInstallation:(NSString *)installationId;

@end
