//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface SBConnectionString : NSObject

+ (NSString *)stringWithEndpoint:(NSURL *)endpoint issuer:(NSString *)issuer issuerSecret:(NSString *)secret DEPRECATED_MSG_ATTRIBUTE("SBConnectionString is deprecated. Use the ANHNotificationHub API instead.");

+ (NSString *)stringWithEndpoint:(NSURL *)endpoint fullAccessSecret:(NSString *)fullAccessSecret DEPRECATED_MSG_ATTRIBUTE("SBConnectionString is deprecated. Use the ANHNotificationHub API instead.");

+ (NSString *)stringWithEndpoint:(NSURL *)endpoint listenAccessSecret:(NSString *)listenAccessSecret DEPRECATED_MSG_ATTRIBUTE("SBConnectionString is deprecated. Use the ANHNotificationHub API instead.");

+ (NSString *)stringWithEndpoint:(NSURL *)endpoint sharedAccessKeyName:(NSString *)keyName accessSecret:(NSString *)secret DEPRECATED_MSG_ATTRIBUTE("SBConnectionString is deprecated. Use the ANHNotificationHub API instead.");

@end
