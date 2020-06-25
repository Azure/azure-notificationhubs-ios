//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MSInstallation.h"

@interface MSInstallation()

- (instancetype)initWithDeviceToken:(NSString *)deviceToken;

+ (instancetype)createFromDeviceToken:(NSString *)deviceToken;
+ (instancetype)createFromJsonString:(NSString *)jsonString;

@property(nonatomic, copy) NSDictionary<NSString *, MSInstallationTemplate *> *templates;
@property(nonatomic, copy) NSSet<NSString *> *tags;

@end
