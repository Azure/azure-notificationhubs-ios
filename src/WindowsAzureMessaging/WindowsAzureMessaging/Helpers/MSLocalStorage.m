// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "MSLocalStorage.h"

@implementation MSLocalStorage

+ (MSInstallation *)upsertInstallation:(MSInstallation *)installation {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:installation];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"installation"];
    [defaults synchronize];
    
    return installation;
}

+ (MSInstallation *)loadInstallation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"installation"];
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}

@end
