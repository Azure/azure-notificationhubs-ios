//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSDebounceInstallationManager.h"

@interface MSDebounceInstallationManager()

@property (nonatomic, readonly) double interval;
@property (nonatomic, strong) NSTimer *debounceTimer;
@property (nonatomic, readonly) MSInstallationManager *installationManager;

@property (nonatomic) InstallationEnrichmentHandler enrichmentHandler;
@property (nonatomic) InstallationManagementHandler managementHandler;
@property (nonatomic) InstallationCompletionHandler completionHandler;

@end
