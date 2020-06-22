//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSDebounceInstallationManager.h"
#import "MSDebounceInstallationManager+Private.h"
#import "MSInstallation.h"
#import "MSInstallationManager.h"
#import "MSLocalStorage.h"

@implementation MSDebounceInstallationManager

- (instancetype)initWithInterval:(double)interval installationManager:(MSInstallationManager *)installationManager {
    if ((self = [super init]) != nil) {
        _interval = interval;
        _installationManager = installationManager;
    }

    return self;
}

- (void)saveInstallation:(MSInstallation *)installation
    withEnrichmentHandler:(InstallationEnrichmentHandler)enrichmentHandler
    withManagementHandler:(InstallationManagementHandler)managementHandler
        completionHandler:(InstallationCompletionHandler)completionHandler {
    if (self.debounceTimer != nil) {
        [self.debounceTimer invalidate];
    }

    self.enrichmentHandler = enrichmentHandler;
    self.managementHandler = managementHandler;
    self.completionHandler = completionHandler;

    self.debounceTimer = [NSTimer scheduledTimerWithTimeInterval:self.interval
                                                      target:self
                                                    selector:@selector(execute)
                                                    userInfo:installation
                                                     repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:self.debounceTimer forMode:NSRunLoopCommonModes];
}

- (void)execute {
    MSInstallation *lastInstallation = [MSLocalStorage loadLastInstallation];
    MSInstallation *installation = [self.debounceTimer userInfo];
    if (![installation isEqual:lastInstallation]) {
        [self.installationManager saveInstallation:installation
                             withEnrichmentHandler:self.enrichmentHandler
                             withManagementHandler:self.managementHandler
                                 completionHandler:self.completionHandler];
    }
}

@end
