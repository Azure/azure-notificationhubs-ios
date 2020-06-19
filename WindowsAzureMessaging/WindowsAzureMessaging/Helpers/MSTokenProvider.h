//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface MSTokenProvider : NSObject {

  @private
    NSString *_sharedAccessKey;
    NSString *_sharedAccessKeyName;
    NSString *_sharedSecret;
    NSString *_sharedSecretIssurer;
    NSURL *_stsHostName;
    NSURL *_serviceEndPoint;
}

@property(nonatomic) NSInteger timeToExpireinMins;
+ (MSTokenProvider *)createFromConnectionDictionary:(NSDictionary *)connectionDictionary;

- (MSTokenProvider *)initWithConnectionDictionary:(NSDictionary *)connectionDictionary;
- (NSString *)generateSharedAccessTokenWithUrl:(NSString *)audienceUri;
@end
