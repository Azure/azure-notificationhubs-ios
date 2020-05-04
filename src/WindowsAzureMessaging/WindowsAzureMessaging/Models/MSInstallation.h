// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#ifndef MSInstallation_h
#define MSInstallation_h

#import <Foundation/Foundation.h>

@interface MSInstallation : NSObject <NSCoding>

@property(nonatomic, copy) NSString *installationID, *pushChannel, *platform;
@property(nonatomic, copy) NSArray<NSString *> *tags;

- (instancetype) initWithDeviceToken:(NSString *) deviceToken;

+ (MSInstallation *) createFromDeviceToken:(NSString *) deviceToken;
+ (MSInstallation *) createFromJsonString: (NSString *) jsonString;

- (NSData *) toJsonData;

- (BOOL) addTags:(NSArray<NSString *> *) tags;
- (BOOL) removeTags:(NSArray<NSString *> *) tags;
- (NSArray<NSString *> *) getTags;
- (void) clearTags;

@end

#endif /* MSInstallation_h */
