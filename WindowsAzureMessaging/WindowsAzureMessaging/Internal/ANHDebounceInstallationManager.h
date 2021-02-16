//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHInstallationEnrichmentDelegate.h"
#import "ANHInstallationManager.h"
#import <Foundation/Foundation.h>

@class ANHInstallation;

NS_ASSUME_NONNULL_BEGIN

@interface ANHDebounceInstallationManager : NSObject

- (instancetype)initWithInterval:(double)interval installationManager:(ANHInstallationManager *)installationManager;
- (void)saveInstallation:(ANHInstallation *)installation
    withEnrichmentHandler:(InstallationEnrichmentHandler)enrichmentHandler
    withManagementHandler:(InstallationManagementHandler)managementHandler
        completionHandler:(InstallationCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
