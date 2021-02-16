//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ANHNotificationHub;
@class ANHInstallation;

@protocol ANHInstallationManagementDelegate <NSObject>

@optional

/**
 *Method that allows to save installation to custom back end
 *
 * @param installation The instance of ANHInstallation that user can save
 */
- (void)notificationHub:(ANHNotificationHub *)notificationHub
    willUpsertInstallation:(ANHInstallation *)installation
         completionHandler:(void (^)(NSError *_Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
