//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class MSInstallationTemplate;

@interface MSInstallation : NSObject <NSCoding>

@property(nonatomic, copy) NSString *installationID, *pushChannel;
@property(nonatomic, readonly, copy) NSDictionary<NSString *, MSInstallationTemplate *> *templates;
@property(nonatomic, readonly, copy) NSSet<NSString *> *tags;

- (instancetype)initWithDeviceToken:(NSString *)deviceToken;

+ (MSInstallation *)createFromDeviceToken:(NSString *)deviceToken;
+ (MSInstallation *)createFromJsonString:(NSString *)jsonString;

- (NSData *)toJsonData;

- (BOOL)addTag:(NSString *)tag;
- (BOOL)addTags:(NSArray<NSString *> *)tags;
- (BOOL)removeTag:(NSString *)tag;
- (BOOL)removeTags:(NSArray<NSString *> *)tags;
- (NSArray<NSString *> *)getTags;
- (void)clearTags;

- (BOOL)addTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key;
- (BOOL)removeTemplate:(NSString *)key;
- (MSInstallationTemplate *)getTemplate:(NSString *)key;

@end
