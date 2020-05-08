//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface MSInstallation : NSObject <NSCoding>

@property(nonatomic, copy) NSString *installationID, *pushChannel, *platform;
@property(nonatomic, copy) NSSet<NSString *> *tags;

- (instancetype)initWithDeviceToken:(NSString *)deviceToken;

+ (MSInstallation *)createFromDeviceToken:(NSString *)deviceToken;
+ (MSInstallation *)createFromJsonString:(NSString *)jsonString;

- (NSData *)toJsonData;

- (BOOL)addTags:(NSSet<NSString *> *)tags;
- (BOOL)removeTags:(NSSet<NSString *> *)tags;
- (NSSet<NSString *> *)getTags;
- (void)clearTags;

@end
