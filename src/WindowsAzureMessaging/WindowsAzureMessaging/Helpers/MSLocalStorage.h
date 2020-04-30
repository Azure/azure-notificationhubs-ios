// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSInstallation.h"

@interface MSLocalStorage : NSObject

+ (void) saveInstallation: (MSInstallation*) installation;
+ (void) updateInstallation: (MSInstallation*) installation;
+ (MSInstallation *)loadInstallationFromLocalStorage;
@end
