//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHInstallation.h"
#import <Foundation/Foundation.h>

@interface ANHLocalStorage : NSObject

+ (BOOL)isEnabled;
+ (void)setEnabled:(BOOL)enabled;

+ (ANHInstallation *)upsertInstallation:(ANHInstallation *)installation;
+ (ANHInstallation *)loadInstallation;

+ (ANHInstallation *)upsertLastInstallation:(ANHInstallation *)installation;
+ (ANHInstallation *)loadLastInstallation;
@end
