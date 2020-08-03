//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSDebounceInstallationManager.h"
#import "MSInstallation.h"
#import "MSInstallationManager.h"
#import "MSLocalStorage.h"

@implementation MSDebounceInstallationManager {
  @private
    double _interval;
    NSTimer *_debounceTimer;
    MSInstallationManager *_installationManager;
    InstallationEnrichmentHandler _enrichmentHandler;
    InstallationManagementHandler _managementHandler;
    InstallationCompletionHandler _completionHandler;
}

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
    if (_debounceTimer != nil) {
        [_debounceTimer invalidate];
    }

    _enrichmentHandler = enrichmentHandler;
    _managementHandler = managementHandler;
    _completionHandler = completionHandler;

    _debounceTimer = [NSTimer scheduledTimerWithTimeInterval:_interval
                                                      target:self
                                                    selector:@selector(execute)
                                                    userInfo:installation
                                                     repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:_debounceTimer forMode:NSRunLoopCommonModes];
}

- (void)execute {
    MSInstallation *lastInstallation = [MSLocalStorage loadLastInstallation];
    MSInstallation *installation = [_debounceTimer userInfo];
    if (![installation isEqual:lastInstallation]) {
        [_installationManager saveInstallation:installation
                         withEnrichmentHandler:_enrichmentHandler
                         withManagementHandler:_managementHandler
                             completionHandler:_completionHandler];
    }
}

@end
