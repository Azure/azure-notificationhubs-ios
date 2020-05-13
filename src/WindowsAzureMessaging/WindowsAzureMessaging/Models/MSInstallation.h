//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class MSInstallationTemplate;

@interface MSInstallation : NSObject <NSCoding>

@property(nonatomic, copy) NSString *installationID, *pushChannel;
@property(nonatomic, copy) NSDictionary<NSString *, MSInstallationTemplate *> *templates;
@property(nonatomic, copy) NSSet<NSString *> *tags;

- (instancetype)initWithDeviceToken:(NSString *)deviceToken;

+ (MSInstallation *)createFromDeviceToken:(NSString *)deviceToken;
+ (MSInstallation *)createFromJsonString:(NSString *)jsonString;

- (NSData *)toJsonData;

- (BOOL)addTags:(NSArray<NSString *> *)tags;
- (BOOL)removeTags:(NSArray<NSString *> *)tags;
- (NSArray<NSString *> *)getTags;
- (void)clearTags;

- (BOOL) addTemplate: (MSInstallationTemplate *) template forKey: (NSString *) key;
- (BOOL) removeTemplate: (NSString *) key;
- (MSInstallationTemplate *) getTemplate: (NSString *) key;

- (NSDictionary *) toDictionary;

@end
