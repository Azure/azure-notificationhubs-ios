// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#ifndef MSInstallation_h
#define MSInstallation_h

#import <Foundation/Foundation.h>

@interface MSInstallation : NSObject <NSCoding>

@property(nonatomic, copy) NSString *installationID, *pushChannel, *platform;
@property() BOOL pushChannelExpired;
@property(nonatomic, copy) NSDate *expirationTime;

- (instancetype) initWithDeviceToken:(NSString *) deviceToken;

+ (MSInstallation *) createFromDeviceToken:(NSString *) deviceToken;
+ (MSInstallation *) createFromJsonString: (NSString *) jsonString;

- (NSData *) toJsonData;

@end

#endif /* MSInstallation_h */
