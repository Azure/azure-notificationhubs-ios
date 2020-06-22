//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface MSTokenProvider : NSObject

@property(nonatomic) NSInteger timeToExpireinMins;

+ (MSTokenProvider *)createFromConnectionDictionary:(NSDictionary *)connectionDictionary;

- (MSTokenProvider *)initWithConnectionDictionary:(NSDictionary *)connectionDictionary;
- (NSString *)generateSharedAccessTokenWithUrl:(NSString *)audienceUri;
@end
