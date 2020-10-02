//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallationManager.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ANHHttpClient;
@class MSTokenProvider;

@interface MSInstallationManager ()

@property(nonatomic, strong) ANHHttpClient *httpClient;
@property(nonatomic, copy) NSString *connectionString;
@property(nonatomic, copy) NSString *hubName;
@property(nonatomic, strong) MSTokenProvider *tokenProvider;
@property(nonatomic, strong) NSDictionary *connectionDictionary;

@end

NS_ASSUME_NONNULL_END
