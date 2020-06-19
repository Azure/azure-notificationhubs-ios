//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

// Legacy API
#if !TARGET_OS_OSX
#import "SBConnectionString.h"
#import "SBNotificationHub.h"
#endif

// New API
#import "MSInstallation.h"
#import "MSInstallationEnrichmentDelegate.h"
#import "MSInstallationLifecycleDelegate.h"
#import "MSInstallationManagementDelegate.h"
#import "MSInstallationTemplate.h"
#import "MSNotificationHub.h"
#import "MSNotificationHubAppDelegate.h"
#import "MSUserNotificationCenterDelegate.h"
#import "MSNotificationHubDelegate.h"
#import "MSNotificationHubMessage.h"
