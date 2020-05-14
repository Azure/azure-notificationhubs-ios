//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface MSInstallation : NSObject <NSCoding>

@property(nonatomic, copy) NSString *installationID, *pushChannel;
@property(nonatomic, copy) NSSet<NSString *> *tags;

- (instancetype)initWithDeviceToken:(NSString *)deviceToken;

+ (MSInstallation *)createFromDeviceToken:(NSString *)deviceToken;
+ (MSInstallation *)createFromJsonString:(NSString *)jsonString;

- (NSData *)toJsonData;

- (BOOL)addTags:(NSArray<NSString *> *)tags;
- (BOOL)removeTags:(NSArray<NSString *> *)tags;
- (NSArray<NSString *> *)getTags;
- (void)clearTags;

@end
