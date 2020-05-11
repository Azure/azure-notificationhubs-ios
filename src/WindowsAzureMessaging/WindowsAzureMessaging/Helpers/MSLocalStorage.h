//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MSInstallation.h"

@interface MSLocalStorage : NSObject

+ (BOOL)isEnabled;
+ (void)setEnabled:(BOOL)enabled;

+ (MSInstallation *)upsertInstallation:(MSInstallation *)installation;
+ (MSInstallation *)loadInstallation;

+ (MSInstallation *)upsertLastInstallation:(MSInstallation *)installation;
+ (MSInstallation *)loadLastInstallation;
@end
