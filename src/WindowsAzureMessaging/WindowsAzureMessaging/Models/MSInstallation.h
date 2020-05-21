//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSChangeTracking.h"
#import "MSTaggable.h"
#import <Foundation/Foundation.h>

@class MSInstallationTemplate;

@interface MSInstallation : NSObject <NSCoding, MSTaggable, MSChangeTracking>

@property(nonatomic, copy) NSString *installationID, *pushChannel;
@property(nonatomic, readonly, copy) NSDictionary<NSString *, MSInstallationTemplate *> *templates;

- (instancetype)initWithDeviceToken:(NSString *)deviceToken;

+ (instancetype)createFromDeviceToken:(NSString *)deviceToken;
+ (instancetype)createFromJsonString:(NSString *)jsonString;

- (NSData *)toJsonData;

- (BOOL)setTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key;
- (BOOL)removeTemplateForKey:(NSString *)key;
- (MSInstallationTemplate *)getTemplateForKey:(NSString *)key;

@end
