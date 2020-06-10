//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
         completionHandler:(void (^)(NSError *_Nullable))completionHandler;

/**
 Method that allows to delete installation from custom backend
 *
 @param installationId The id of installation to delete from custom back end
 */
- (void)notificationHub:(MSNotificationHub *)notificationHub
    willDeleteInstallation:(NSString *)installationId
         completionHandler:(void (^)(NSError *_Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
