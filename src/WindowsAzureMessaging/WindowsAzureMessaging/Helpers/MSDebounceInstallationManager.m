//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSDebounceInstallationManager.h"
#import "MSInstallation.h"
#import "MSInstallationManager.h"
#import "MSLocalStorage.h"

@implementation MSDebounceInstallationManager

- (instancetype)initWithInterval:(double)interval installationManager:(MSInstallationManager *)installationManager {
    if (self = [super init]) {
        _interval = interval;
        _installationManager = installationManager;
    }

    return self;
}

- (void)saveInstallation:(MSInstallation *)installation
    withEnrichmentHandler:(InstallationEnrichmentHandler)enrichmentHandler
    withManagementHandler:(InstallationManagementHandler)managementHandler {
    if (_debounceTimer != nil) {
        [_debounceTimer invalidate];
    }

    _enrichmentHandler = enrichmentHandler;
    _managementHandler = managementHandler;

    MSInstallation *lastInstallation = [MSLocalStorage loadLastInstallation];

    if (![installation isEqual:lastInstallation]) {
        _debounceTimer = [NSTimer scheduledTimerWithTimeInterval:_interval
                                                          target:self
                                                        selector:@selector(execute)
                                                        userInfo:installation
                                                         repeats:false];
        [[NSRunLoop mainRunLoop] addTimer:_debounceTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)execute {
    MSInstallation *installation = [_debounceTimer userInfo];
    [_installationManager saveInstallation:installation withEnrichmentHandler:_enrichmentHandler withManagementHandler:_managementHandler];
}

@end
