//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface MSInstallationTemplate : NSObject

@property(nonatomic, copy) NSString *body;
@property(nonatomic, copy, readonly) NSSet<NSString *> *tags;
@property(nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *headers;

- (BOOL)addTag:(NSString *)tag;
- (BOOL)addTags:(NSArray<NSString *> *)tagsToAdd;
- (BOOL)removeTag:(NSString *)tag;
- (BOOL)removeTags:(NSArray<NSString *> *)tagsToRemove;
- (void)clearTags;

// Headers
- (void)setHeader:(NSString *)value forKey:(NSString *)key;
- (void)removeHeader:(NSString *)key;
- (NSString *)getHeader:(NSString *)key;
- (NSDictionary<NSString *, NSString *> *)getHeaders;

// Serialize
- (NSDictionary *)toDictionary;

@end
