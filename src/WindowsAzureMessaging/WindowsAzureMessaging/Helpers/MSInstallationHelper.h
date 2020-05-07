// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

@class MSInstallation

    @interface MSInstallationHelper : NSObject
+ (MSInstallation *)createInstallation:(NSString *)connectionString + (MSInstallation *)
                    updateInstallation:(MSInstallation *)installation @end
