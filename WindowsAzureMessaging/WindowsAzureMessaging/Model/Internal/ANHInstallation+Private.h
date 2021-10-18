//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "ANHInstallation.h"

@interface ANHInstallation()

- (instancetype)initWithDeviceToken:(NSString *)deviceToken;

@property(nonatomic, copy) NSDictionary<NSString *, ANHInstallationTemplate *> *templates;
@property(nonatomic, copy) NSSet<NSString *> *tags;

@end
