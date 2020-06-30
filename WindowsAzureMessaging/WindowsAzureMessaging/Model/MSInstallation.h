//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSChangeTracking.h"
#import "MSTaggable.h"
#import <Foundation/Foundation.h>

@class MSInstallationTemplate;

@interface MSInstallation : NSObject <NSCoding, MSTaggable, MSChangeTracking>

@property(nonatomic, copy) NSString *installationId, *pushChannel;
@property(nonatomic, copy) NSDate *expirationTime;
@property(nonatomic, readonly, copy) NSDictionary<NSString *, MSInstallationTemplate *> *templates;

- (NSData *)toJsonData;

- (BOOL)setTemplate:(MSInstallationTemplate *)template forKey:(NSString *)key;
- (BOOL)removeTemplateForKey:(NSString *)key;
- (MSInstallationTemplate *)getTemplateForKey:(NSString *)key;

@end
