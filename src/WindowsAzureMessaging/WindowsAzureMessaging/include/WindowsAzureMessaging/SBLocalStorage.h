//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "SBStoredRegistrationEntry.h"
#import <Foundation/Foundation.h>

@class SBRegistration;

@interface SBLocalStorage : NSObject {
  @private
    NSString *_path;
    NSMutableDictionary *_registrations;
    NSString *_versionKey;
    NSString *_deviceTokenKey;
    NSString *_registrationsKey;
}

@property(copy, nonatomic) NSString *deviceToken;
@property(nonatomic) BOOL isRefreshNeeded;

- (SBLocalStorage *)initWithNotificationHubPath:(NSString *)notificationHubPath;
- (void)refreshFinishedWithDeviceToken:(NSString *)newDeviceToken;

- (StoredRegistrationEntry *)getStoredRegistrationEntryWithRegistrationName:(NSString *)registrationName;
- (void)updateWithRegistrationName:(NSString *)registrationName registration:(SBRegistration *)registration;
- (void)updateWithRegistrationName:(NSString *)registrationName
                    registrationId:(NSString *)registrationId
                              eTag:(NSString *)eTag
                       deviceToken:(NSString *)devToken;
- (void)updateWithRegistration:(SBRegistration *)registration;
- (void)deleteWithRegistrationName:(NSString *)registrationName;
- (void)deleteAllRegistrations;

@end