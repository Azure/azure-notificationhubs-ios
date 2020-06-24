//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSNotificationHub.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_OSX
@interface MSNotificationHub () <NSUserNotificationCenterDelegate>
#else
@interface MSNotificationHub ()
#endif

- (NSString *)convertTokenToString:(NSData *)token;

+ (void)resetSharedInstance;

#if TARGET_OS_OSX
@property(nonatomic) id<NSUserNotificationCenterDelegate> originalUserNotificationCenterDelegate;
#endif

@property(nonatomic) id<MSNotificationHubDelegate> delegate;
@property(nonatomic, weak, nullable) id<MSInstallationEnrichmentDelegate> enrichmentDelegate;
@property(nonatomic, weak, nullable) id<MSInstallationManagementDelegate> managementDelegate;
@property(nonatomic, weak, nullable) id<MSInstallationLifecycleDelegate> lifecycleDelegate;

NS_ASSUME_NONNULL_END

@end
