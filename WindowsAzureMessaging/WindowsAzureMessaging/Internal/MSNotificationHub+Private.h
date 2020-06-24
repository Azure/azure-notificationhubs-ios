//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSNotificationHub.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSNotificationHub ()

- (NSString *)convertTokenToString:(NSData *)token;

+ (void)resetSharedInstance;

@property(nonatomic) id<MSNotificationHubDelegate> delegate;
@property(nonatomic, weak, nullable) id<MSInstallationEnrichmentDelegate> enrichmentDelegate;
@property(nonatomic, weak, nullable) id<MSInstallationManagementDelegate> managementDelegate;
@property(nonatomic, weak, nullable) id<MSInstallationLifecycleDelegate> lifecycleDelegate;

NS_ASSUME_NONNULL_END

@end
