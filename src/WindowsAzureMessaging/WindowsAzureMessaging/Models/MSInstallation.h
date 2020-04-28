// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#ifndef MSInstallation_h
#define MSInstallation_h

#import <Foundation/Foundation.h>

@interface MSInstallation : NSObject <NSCoding>

@property(nonatomic, copy, readonly) NSString *installationID;

@end

#endif /* MSInstallation_h */
