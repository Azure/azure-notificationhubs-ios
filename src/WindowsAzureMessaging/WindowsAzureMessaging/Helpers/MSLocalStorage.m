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

+ (MSInstallation *)upsertInstallation:(MSInstallation *)installation forKey:(NSString *)key {
    if ([[NSKeyedArchiver class] respondsToSelector:@selector(archivedDataWithRootObject:requiringSecureCoding:error:)]) {
        NSError *error = nil;
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:installation requiringSecureCoding:NO error:&error];
        [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:key];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations" // Mac Catalyst warnings
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:installation];
#pragma clang diagnostic pop
        [[NSUserDefaults standardUserDefaults] setObject:encodedObject forKey:key];
    }

    return installation;
}

+ (MSInstallation *)loadInstallation {
    return [MSLocalStorage loadInstallationForKey:kInstallationKey];
}

+ (MSInstallation *)loadLastInstallation {
    return [MSLocalStorage loadInstallationForKey:kLastInstallationKey];
}



+ (MSInstallation *)loadInstallationForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];

    if ([[NSKeyedUnarchiver class] respondsToSelector:@selector(unarchivedObjectOfClass:fromData:error:)]) {
        NSError *error = nil;
        return [NSKeyedUnarchiver unarchivedObjectOfClass:[MSInstallation class] fromData:encodedObject error:&error];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations" // Mac Catalyst warnings
    return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
#pragma clang diagnostic pop
}



@end
