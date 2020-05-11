//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSLocalStorage.h"
#import <Foundation/Foundation.h>

static NSString *const installationKey = @"installation";
static NSString *const lastInstallationKey = @"lastInstallation";
static NSString *const enabledKey = @"notificationHubEnabled";

@implementation MSLocalStorage

+ (BOOL)isEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:enabledKey];
    if (encodedObject == nil) {
        return YES;
    }

    NSNumber *enabledNumber = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    return [enabledNumber boolValue];
}

+ (void)setEnabled:(BOOL)enabled {
    NSNumber *enabledNumber = [NSNumber numberWithBool:enabled];
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:enabledNumber];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:enabledKey];
    [defaults synchronize];
}

+ (MSInstallation *)upsertInstallation:(MSInstallation *)installation {
    return [MSLocalStorage upsertInstallation:installation forKey:installationKey];
}

+ (MSInstallation *)upsertLastInstallation:(MSInstallation *)installation {
    return [MSLocalStorage upsertInstallation:installation forKey:lastInstallationKey];
}

+ (MSInstallation *)upsertInstallation:(MSInstallation *)installation forKey:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:installation];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];

    return installation;
}

+ (MSInstallation *)loadInstallation {
    return [MSLocalStorage loadInstallationForKey:installationKey];
}

+ (MSInstallation *)loadLastInstallation {
    return [MSLocalStorage loadInstallationForKey:lastInstallationKey];
}

+ (MSInstallation *)loadInstallationForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];

    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}

@end
