// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#ifndef MSInstallation_h
#define MSInstallation_h

#import <Foundation/Foundation.h>

@interface MSInstallation : NSObject <NSCoding>

@property(nonatomic, copy) NSString *installationID, *pushChannel, *platform;
@property() BOOL pushChannelExpired;
@property(nonatomic, copy) NSDate *expirationTime;

- (NSData *) toJsonData;
- (BOOL) updateWithJson: (NSString *) jsonString;

@end

#endif /* MSInstallation_h */
