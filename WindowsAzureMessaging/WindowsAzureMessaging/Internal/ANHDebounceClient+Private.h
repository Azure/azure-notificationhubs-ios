//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#include "ANHDebounceClient.h"

@interface ANHDebounceClient ()

@property (nonatomic) double interval;
@property (nonatomic, strong) NSTimer *debounceTimer;
@property (nonatomic) InstallationEnrichmentHandler enrichmentHandler;
@property (nonatomic) InstallationManagementHandler managementHandler;
@property (nonatomic) InstallationCompletionHandler completionHandler;

@end
