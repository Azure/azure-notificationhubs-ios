//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_LOCAL_STORAGE_H
#define ANH_LOCAL_STORAGE_H

#import <Foundation/Foundation.h>

static NSString * const kANHInstallationKey = @"ANH_Installation";
static NSString * const kANHLastInstallationKey = @"ANH_LastInstallation";

static NSString * const kANHVoIPInstallationKey = @"ANH_VoIPInstallation";
static NSString * const kANHVoIPLastInstallationKey = @"ANH_VoIPLastInstallation";

NS_SWIFT_NAME(LocalStorage)
@interface ANHLocalStorage : NSObject

+ (id)setObject:(id)data forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;
+ (void)clearForKey:(NSString *)key;

@end

#endif
