// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

@class MSInstallation;
@class MSTokenProvider;

@interface MSInstallationManager : NSObject {

@private
    MSTokenProvider* tokenProvider;
    NSDictionary* connectionDictionary;
    NSString* pushToken;
}

+ (void) initWithConnectionString:(NSString *) connectionString withHubName:(NSString *) hubName;

+ (void) saveInstallation;
+ (void) setPushChannel:(NSString *) pushChannel;
+ (BOOL) addTags:(NSArray<NSString *> *) tags;
+ (BOOL) removeTags:(NSArray<NSString *> *) tags;
+ (NSArray<NSString *> *) getTags;
+ (void) clearTags;
+ (MSInstallation *) getInstallation;

- (void) saveInstallation;

@end
