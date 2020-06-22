//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallationManager.h"
#import <Foundation/Foundation.h>

@class MSHttpClient;

@interface MSInstallationManager ()

@property (nonatomic, copy) NSString *connectionString;

@property (nonatomic, copy) NSString *hubName;

@property (nonatomic, strong) MSTokenProvider *tokenProvider;

@property (nonatomic, copy) NSDictionary *connectionDictionary;

- (NSString *)getOsVersion;

- (NSString *)getOsName;

@end
