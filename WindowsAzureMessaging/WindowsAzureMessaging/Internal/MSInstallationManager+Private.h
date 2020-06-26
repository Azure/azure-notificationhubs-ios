//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MSInstallationManager.h"

NS_ASSUME_NONNULL_BEGIN

@class MSHttpClient;

@interface MSInstallationManager()

@property(nonatomic) MSHttpClient *httpClient;

@end

NS_ASSUME_NONNULL_END
