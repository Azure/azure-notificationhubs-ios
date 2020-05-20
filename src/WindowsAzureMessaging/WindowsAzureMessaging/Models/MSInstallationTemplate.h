//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MSTaggable.h"

@interface MSInstallationTemplate : NSObject<MSTaggable>

@property(nonatomic, copy) NSString *body;
@property(nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *headers;

// Headers
- (void)setHeader:(NSString *)value forKey:(NSString *)key;
- (void)removeHeader:(NSString *)key;
- (NSString *)getHeader:(NSString *)key;
- (NSDictionary<NSString *, NSString *> *)getHeaders;

// Serialize
- (NSDictionary *)toDictionary;

@end
