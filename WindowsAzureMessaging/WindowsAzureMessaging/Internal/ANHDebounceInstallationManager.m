//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHDebounceInstallationManager.h"
#import "ANHInstallation.h"
#import "ANHInstallationManager.h"
#import "ANHLocalStorage.h"

@interface ANHDebounceInstallationManager ()

@property(nonatomic) double interval;
@property(nonatomic, strong) NSTimer *debounceTimer;
@property(nonatomic, strong) ANHInstallationManager *installationManager;
@property(nonatomic) InstallationEnrichmentHandler enrichmentHandler;
@property(nonatomic) InstallationManagementHandler managementHandler;
@property(nonatomic) InstallationCompletionHandler completionHandler;

@end

@implementation ANHDebounceInstallationManager

- (instancetype)initWithInterval:(double)interval installationManager:(ANHInstallationManager *)installationManager {
    if ((self = [super init]) != nil) {
        _interval = interval;
        _installationManager = installationManager;
    }

    return self;
}

- (void)saveInstallation:(ANHInstallation *)installation
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
    ANHInstallation *lastInstallation = [ANHLocalStorage loadLastInstallation];
    ANHInstallation *installation = [_debounceTimer userInfo];
    if (![installation isEqual:lastInstallation]) {
        [_installationManager saveInstallation:installation
                         withEnrichmentHandler:_enrichmentHandler
                         withManagementHandler:_managementHandler
                             completionHandler:_completionHandler];
    }
}

@end
