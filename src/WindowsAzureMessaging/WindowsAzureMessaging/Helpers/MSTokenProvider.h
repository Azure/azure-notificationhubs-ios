// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

@interface MSTokenProvider : NSObject {

@private
    NSString* _sharedAccessKey;
    NSString* _sharedAccessKeyName ;
    NSString* _sharedSecret;
    NSString* _sharedSecretIssurer;
    NSURL* _stsHostName;
    NSURL* _serviceEndPoint;
}

@property (nonatomic) NSInteger timeToExpireinMins;

- (MSTokenProvider*) initWithConnectionDictionary: (NSDictionary*) connectionDictionary;
- (NSString *) generateSharedAccessTokenWithUrl:(NSString*)audienceUri;
@end
