// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSInstallation.h"

@interface MSLocalStorage : NSObject

+ (MSInstallation *)upsertInstallation:(MSInstallation *)installation;
+ (MSInstallation *)loadInstallation;

+ (MSInstallation *)upsertLastInstallation:(MSInstallation *)installation;
+ (MSInstallation *)loadLastInstallation;
@end
