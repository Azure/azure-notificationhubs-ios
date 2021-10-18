//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "ANHInstallationClient.h"

@class ANHConnection;
@class ANHHttpClient;
@class ANHTokenProvider;

@interface ANHInstallationClient ()

@property (nonatomic, strong) ANHConnection *connectionString;
@property (nonatomic, strong) ANHHttpClient *httpClient;
@property (nonatomic, strong) ANHTokenProvider *tokenProvider;
@property (nonatomic, copy) NSString *hubName;

- (void)setDefaultExpiration:(ANHInstallation *)installation;
@property (nonatomic, copy, readonly, getter=getOSVersion) NSString *osVersion;
@property (nonatomic, copy, readonly, getter=getOSName) NSString *osName;

@end
