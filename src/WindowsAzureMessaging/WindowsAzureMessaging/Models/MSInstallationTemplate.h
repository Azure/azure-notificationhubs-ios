// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

@interface MSInstallationTemplate : NSObject

@property(nonatomic, copy) NSString *body;
@property(nonatomic, copy) NSMutableArray<NSString *> *tags;
@property(nonatomic, copy) NSMutableDictionary<NSString *, NSString*> *headers;

@end
