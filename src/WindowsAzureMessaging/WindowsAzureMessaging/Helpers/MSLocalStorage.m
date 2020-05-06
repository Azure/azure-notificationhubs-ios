// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "MSLocalStorage.h"

static NSString * const installationKey = @"installation";
static NSString * const lastInstallationKey = @"lastInstallation";

@implementation MSLocalStorage

+ (MSInstallation *)upsertInstallation:(MSInstallation *)installation {
    return [MSLocalStorage upsertInstallation:installation forKey:installationKey];
}

+ (MSInstallation *)upsertLastInstallation:(MSInstallation *)installation {
    return [MSLocalStorage upsertInstallation:installation forKey:lastInstallationKey];
}

+ (MSInstallation *) upsertInstallation:(MSInstallation *)installation forKey:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:installation];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
    return installation;
}

+ (MSInstallation *)loadInstallation {
    return [MSLocalStorage loadLastInstallationForKey:installationKey];
}

+ (MSInstallation *)loadLastInstallation {
    return [MSLocalStorage loadLastInstallationForKey:lastInstallationKey];
}

+ (MSInstallation *)loadLastInstallationForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}

@end
