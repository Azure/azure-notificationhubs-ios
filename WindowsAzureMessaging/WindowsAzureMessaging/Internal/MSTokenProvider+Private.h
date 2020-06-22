//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSTokenProvider.h"

@interface MSTokenProvider ()

@property (nonatomic, copy) NSString *sharedAccessKey;
@property (nonatomic, copy) NSString *sharedAccessKeyName;
@property (nonatomic, copy) NSString *sharedSecret;
@property (nonatomic, copy) NSString *sharedSecretIssurer;
@property (nonatomic, strong) NSURL *stsHostName;
@property (nonatomic, strong) NSURL *serviceEndPoint;

@end
