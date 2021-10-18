//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_CONNECTION_h
#define ANH_CONNECTION_h

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(Connection)
@interface ANHConnection : NSObject

- (instancetype)initWithConnectionString:(NSString *)connectionString;

@property(nonatomic, copy) NSString *sharedAccessKey;
@property(nonatomic, copy) NSString *sharedAccessKeyName;
@property(nonatomic, copy) NSString *sharedSecret;
@property(nonatomic, copy) NSString *sharedSecretIssurer;
@property(nonatomic, strong) NSURL *stsHostName;
@property(nonatomic, strong) NSURL *serviceEndPoint;

@end

#endif
