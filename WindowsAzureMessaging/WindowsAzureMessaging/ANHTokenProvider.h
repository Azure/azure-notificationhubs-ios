//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_TOKEN_PROVIDER_H
#define ANH_TOKEN_PROVIDER_H

#import <Foundation/Foundation.h>
#import "ANHConnection.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(TokenProvider)
@interface ANHTokenProvider : NSObject

@property(nonatomic) NSInteger timeToExpireinMins;

- (id)initWithConnectionString:(ANHConnection *)connectionString;
- (NSString *)generateSharedAccessTokenWithUrl:(NSString *)audienceUri;

@end

NS_ASSUME_NONNULL_END

#endif
