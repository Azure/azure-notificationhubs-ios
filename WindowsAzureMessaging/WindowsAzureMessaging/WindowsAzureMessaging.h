//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

// Legacy API
#if !TARGET_OS_OSX
#import "SBConnectionString.h"
#import "SBNotificationHub.h"
#endif

// New API
#import "ANHInstallation.h"
#import "ANHInstallationEnrichmentDelegate.h"
#import "ANHInstallationLifecycleDelegate.h"
#import "ANHInstallationManagementDelegate.h"
#import "ANHInstallationTemplate.h"
#import "ANHNotificationHubOptions.h"
#import "ANHNotificationHub.h"
#import "ANHNotificationHubDelegate.h"
#import "ANHNotificationHubMessage.h"
