//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_ERRORS_H
#define ANH_ERRORS_H

#import <Foundation/Foundation.h>

#define ANH_NOTIFICATION_HUB_BASE_DOMAIN @"com.Microsoft.AzureNotificationHubs."

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Domain

static NSString *const kANHErrorDomain = ANH_NOTIFICATION_HUB_BASE_DOMAIN @"ErrorDomain";

#pragma mark - General

// Error codes.
NS_ENUM(NSInteger){ANHCanceledErrorCode = 1, ANHDisabledErrorCode = 2};

// Error descriptions.
static NSString const *kANHCanceledErrorDesc = @"The operation was canceled.";
static NSString const *kANHDisabledErrorDesc = @"The service is disabled.";

NS_ASSUME_NONNULL_END

#endif
