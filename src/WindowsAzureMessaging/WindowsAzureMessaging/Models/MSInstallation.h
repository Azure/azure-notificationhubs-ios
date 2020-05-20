//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MSTaggable.h"

@class MSInstallationTemplate;

@interface MSInstallation : NSObject <NSCoding, MSTaggable>

@property(nonatomic, copy) NSString *installationID, *pushChannel;
@property(nonatomic, readonly, copy) NSDictionary<NSString *, MSInstallationTemplate *> *templates;


- (instancetype)initWithDeviceToken:(NSString *)deviceToken;

+ (MSInstallation *)createFromDeviceToken:(NSString *)deviceToken;
+ (MSInstallation *)createFromJsonString:(NSString *)jsonString;

- (NSData *)toJsonData;

- (BOOL)addTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key;
- (BOOL)removeTemplate:(NSString *)key;
- (MSInstallationTemplate *)getTemplate:(NSString *)key;

@end
