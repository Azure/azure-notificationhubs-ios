// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

@class MSInstallation;
@class MSTokenProvider;

@interface MSInstallationManager : NSObject {

@private
    MSTokenProvider* _tokenProvider;
    NSDictionary* _connectionDictionary;
    NSString* _hubName;
    NSString* _pushToken;
}

- (MSInstallationManager *) initWithConnectionString:(NSString *) connectionString withHubName:(NSString *) hubName;
- (MSInstallation *) getInstallation:(NSString *) pushToken;
- (void) upsertInstallationWithDeviceToken: (NSString *) deviceToken;

@end
