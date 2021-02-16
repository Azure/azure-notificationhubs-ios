//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

#import "SBLocalStorage.h"
#import "SBTokenProvider.h"

@interface SBNotificationHub : NSObject

- (SBNotificationHub *)initWithConnectionString:(NSString *)connectionString notificationHubPath:(NSString *)notificationHubPath DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");

// Async operations
- (void)registerNativeWithDeviceToken:(NSData *)deviceToken tags:(NSSet *)tags completion:(void (^)(NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");
- (void)registerTemplateWithDeviceToken:(NSData *)deviceToken
                                   name:(NSString *)name
                       jsonBodyTemplate:(NSString *)bodyTemplate
                         expiryTemplate:(NSString *)expiryTemplate
                                   tags:(NSSet *)tags
                             completion:(void (^)(NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");
- (void)registerTemplateWithDeviceToken:(NSData *)deviceToken
                                   name:(NSString *)name
                       jsonBodyTemplate:(NSString *)bodyTemplate
                         expiryTemplate:(NSString *)expiryTemplate
                       priorityTemplate:(NSString *)priorityTemplate
                                   tags:(NSSet *)tags
                             completion:(void (^)(NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");

- (void)unregisterNativeWithCompletion:(void (^)(NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");
- (void)unregisterTemplateWithName:(NSString *)name completion:(void (^)(NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");

- (void)unregisterAllWithDeviceToken:(NSData *)deviceToken completion:(void (^)(NSError *error))completion DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");

// sync operations
- (BOOL)registerNativeWithDeviceToken:(NSData *)deviceToken tags:(NSSet *)tags error:(NSError **)error DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");
- (BOOL)registerTemplateWithDeviceToken:(NSData *)deviceToken
                                   name:(NSString *)templateName
                       jsonBodyTemplate:(NSString *)bodyTemplate
                         expiryTemplate:(NSString *)expiryTemplate
                                   tags:(NSSet *)tags
                                  error:(NSError **)error DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");
- (BOOL)registerTemplateWithDeviceToken:(NSData *)deviceToken
                                   name:(NSString *)templateName
                       jsonBodyTemplate:(NSString *)bodyTemplate
                         expiryTemplate:(NSString *)expiryTemplate
                       priorityTemplate:(NSString *)priorityTemplate
                                   tags:(NSSet *)tags
                                  error:(NSError **)error DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");

- (BOOL)unregisterNativeWithError:(NSError **)error DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");
- (BOOL)unregisterTemplateWithName:(NSString *)name error:(NSError **)error DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");

- (BOOL)unregisterAllWithDeviceToken:(NSData *)deviceToken error:(NSError **)error DEPRECATED_MSG_ATTRIBUTE("SBNotificationHub is deprecated. Use the ANHNotificationHub API instead.");

@end
