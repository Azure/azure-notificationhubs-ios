//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "ANHInstallationTemplate.h"

@interface ANHInstallationTemplate()

@property(nonatomic, copy) NSSet<NSString *> *tags;
@property(nonatomic, copy) NSDictionary<NSString *, NSString *> *headers;

// Serialize
- (NSDictionary *)toDictionary;

@end
