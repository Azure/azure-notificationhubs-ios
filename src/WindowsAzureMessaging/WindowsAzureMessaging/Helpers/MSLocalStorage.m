// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "MSLocalStorage.h"

@implementation LocalStorage

MSInstallation* currentInstallation;

- (void) saveInstallation: (MSInstallation *) installation {
    [LocalStorage saveInstallationToLocalStorage:installation];
}

- (void) updateInstallation: (MSInstallation *) installation {
    [LocalStorage saveInstallationToLocalStorage:installation];
}

+ (void)saveInstallationToLocalStorage:(MSInstallation *)installation {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:installation requiringSecureCoding:false error: nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"installation"];
    [defaults synchronize];
}

+ (MSInstallation *)loadInstallationFromLocalStorage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:@"installation"];
    
    return [NSKeyedUnarchiver unarchivedObjectOfClass:[MSInstallation class] fromData:encodedObject error: nil];
}

@end
