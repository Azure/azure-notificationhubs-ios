//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHLocalStorage.h"
#import <Foundation/Foundation.h>

static NSString *const kInstallationKey = @"MSNH_Installation";
static NSString *const kLastInstallationKey = @"MSNH_LastInstallation";
static NSString *const kEnabledKey = @"MSNH_NotificationHubEnabled";

@implementation ANHLocalStorage

+ (BOOL)isEnabled {
    NSNumber *enabledNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kEnabledKey];

    return (enabledNumber) ? [enabledNumber boolValue] : YES;
}

+ (void)setEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setObject:@(enabled) forKey:kEnabledKey];
}

+ (ANHInstallation *)upsertInstallation:(ANHInstallation *)installation {
    return [ANHLocalStorage upsertInstallation:installation forKey:kInstallationKey];
}

+ (ANHInstallation *)upsertLastInstallation:(ANHInstallation *)installation {
    return [ANHLocalStorage upsertInstallation:installation forKey:kLastInstallationKey];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (ANHInstallation *)upsertInstallation:(ANHInstallation *)installation forKey:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:installation];
    [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:key];

    return installation;
}
#pragma GCC diagnostic pop

+ (ANHInstallation *)loadInstallation {
    return [ANHLocalStorage loadInstallationForKey:kInstallationKey];
}

+ (ANHInstallation *)loadLastInstallation {
    return [ANHLocalStorage loadInstallationForKey:kLastInstallationKey];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (ANHInstallation *)loadInstallationForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];

    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
}
#pragma GCC diagnostic pop

@end
