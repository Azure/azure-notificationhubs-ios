//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface SBTokenProvider : NSObject {

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-interface-ivars"
  @private
    NSString *_sharedAccessKey;
    NSString *_sharedAccessKeyName;
    NSString *_sharedSecret;
    NSString *_sharedSecretIssurer;
    NSURL *_stsHostName;
    NSURL *_serviceEndPoint;
}

#pragma GCC diagnostic pop

@property(nonatomic) NSInteger timeToExpireinMins;

- (SBTokenProvider *)initWithConnectionDictinary:(NSDictionary *)connectionDictionary;

- (void)setTokenWithRequest:(NSMutableURLRequest *)request completion:(void (^)(NSError *))completion;
- (BOOL)setTokenWithRequest:(NSMutableURLRequest *)request error:(NSError **)error;

@end
