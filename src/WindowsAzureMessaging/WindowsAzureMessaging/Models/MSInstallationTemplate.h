//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MSTaggable.h"
#import "MSChangeTracking.h"

@interface MSInstallationTemplate : NSObject<MSTaggable, MSChangeTracking>

@property(nonatomic, copy) NSString *body;
@property(nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *headers;

// Headers
- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key;
- (void)removeHeaderValueForKey:(NSString *)key;
- (NSString *)getHeaderValueForKey:(NSString *)key;

// Serialize
- (NSDictionary *)toDictionary;

@end
