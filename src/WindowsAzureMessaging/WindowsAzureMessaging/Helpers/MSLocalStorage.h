// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSInstallation.h"

@interface LocalStorage : NSObject

- (void) saveInstallation: (MSInstallation*) installation;
- (void) updateInstallation: (MSInstallation*) installation;
@end
