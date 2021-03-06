//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSLocalStorage.h"
#import <Foundation/Foundation.h>

static NSString *const kInstallationKey = @"MSNH_Installation";
static NSString *const kLastInstallationKey = @"MSNH_LastInstallation";
static NSString *const kEnabledKey = @"MSNH_NotificationHubEnabled";

@implementation MSLocalStorage

+ (BOOL)isEnabled {
    NSNumber *enabledNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kEnabledKey];

    return (enabledNumber) ? [enabledNumber boolValue] : YES;
}

+ (void)setEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setObject:@(enabled) forKey:kEnabledKey];
}

+ (MSInstallation *)upsertInstallation:(MSInstallation *)installation {
    return [MSLocalStorage upsertInstallation:installation forKey:kInstallationKey];
}

+ (MSInstallation *)upsertLastInstallation:(MSInstallation *)installation {
    return [MSLocalStorage upsertInstallation:installation forKey:kLastInstallationKey];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (MSInstallation *)upsertInstallation:(MSInstallation *)installation forKey:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:installation];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:key];

    return installation;
}
#pragma GCC diagnostic pop

+ (MSInstallation *)loadInstallation {
    return [MSLocalStorage loadInstallationForKey:kInstallationKey];
}

+ (MSInstallation *)loadLastInstallation {
    return [MSLocalStorage loadInstallationForKey:kLastInstallationKey];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (MSInstallation *)loadInstallationForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];

    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}
#pragma GCC diagnostic pop

@end
