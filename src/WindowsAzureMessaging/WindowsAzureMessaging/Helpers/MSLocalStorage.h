// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

@class MSInstallation;
@interface LocalStorage : NSObject

- (void) saveInstallation: (MSInstallation*) installation;
- (void) updateInstallation: (MSInstallation*) installation;
@end
