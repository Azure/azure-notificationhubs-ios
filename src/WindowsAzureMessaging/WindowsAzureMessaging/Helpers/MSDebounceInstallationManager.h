//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallationEnrichmentDelegate.h"
#import "MSInstallationManager.h"
#import <Foundation/Foundation.h>

@class MSInstallation;

NS_ASSUME_NONNULL_BEGIN

@interface MSDebounceInstallationManager : NSObject {
  @private
    double _interval;
    NSTimer *_debounceTimer;
    MSInstallationManager *_installationManager;
    InstallationEnrichmentHandler _enrichmentHandler;
}

- (instancetype)initWithInterval:(double)interval installationManager:(MSInstallationManager *)installationManager;
- (void)saveInstallation:(MSInstallation *)installation withEnrichmentHandler:(InstallationEnrichmentHandler)enrichmentHandler;

@end

NS_ASSUME_NONNULL_END
