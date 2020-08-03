//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallation.h"
#import <Foundation/Foundation.h>

@interface MSLocalStorage : NSObject

+ (BOOL)isEnabled;
+ (void)setEnabled:(BOOL)enabled;

+ (MSInstallation *)upsertInstallation:(MSInstallation *)installation;
+ (MSInstallation *)loadInstallation;

+ (MSInstallation *)upsertLastInstallation:(MSInstallation *)installation;
+ (MSInstallation *)loadLastInstallation;
@end
