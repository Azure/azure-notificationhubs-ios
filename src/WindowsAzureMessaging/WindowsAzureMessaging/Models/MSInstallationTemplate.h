//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface MSInstallationTemplate : NSObject

@property(nonatomic, copy) NSString *body;
@property(nonatomic, copy) NSSet<NSString *> *tags;
@property(nonatomic, copy) NSDictionary<NSString *, NSString *> *headers;

- (void)addTag:(NSString *)tags;
- (void)setHeader:(NSString *)value forKey:(NSString *)key;

- (NSDictionary *)toDictionary;

@end
