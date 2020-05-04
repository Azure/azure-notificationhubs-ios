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

+ (MSInstallation *) getInstallation;
+ (void) upsertInstallationWithDeviceToken: (NSString *) deviceToken;

- (MSInstallation *) getInstallation;
- (void) upsertInstallationWithDeviceToken: (NSString *) deviceToken;

@end
