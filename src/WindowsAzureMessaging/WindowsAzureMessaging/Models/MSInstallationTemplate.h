// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

@interface MSInstallationTemplate : NSObject

@property(nonatomic) NSString *body;
@property(nonatomic) NSMutableSet<NSString *> *tags;
@property(nonatomic) NSMutableDictionary<NSString *, NSString*> *headers;

- (NSDictionary *) toDictionary;

@end
