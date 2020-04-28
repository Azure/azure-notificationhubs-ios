// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#ifndef MS_ERRORS_H
#define MS_ERRORS_H

#import <Foundation/Foundation.h>

#define MS_NOTIFICATION_HUB_BASE_DOMAIN @"com.Microsoft.NotificationHub."

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Domain

static NSString *const kMSNHErrorDomain = MS_NOTIFICATION_HUB_BASE_DOMAIN @"ErrorDomain";

#pragma mark - General

// Error codes.
NS_ENUM(NSInteger){MSNHLogInvalidContainerErrorCode = 1, MSNHCanceledErrorCode = 2, MSNHDisabledErrorCode = 3};

// Error descriptions.
static NSString const *kMSNHLogInvalidContainerErrorDesc = @"Invalid log container.";
static NSString const *kMSNHCanceledErrorDesc = @"The operation was canceled.";
static NSString const *kMSNHDisabledErrorDesc = @"The service is disabled.";

#pragma mark - Connection

// Error codes.
NS_ENUM(NSInteger){MSNHConnectionPausedErrorCode = 100, MSNHConnectionHttpErrorCode = 101};

// Error descriptions.
static NSString const *kMSNHConnectionHttpErrorDesc = @"An HTTP error occured.";
static NSString const *kMSNHConnectionPausedErrorDesc = @"Canceled, connection paused with log deletion.";

// Error user info keys.
static NSString const *kMSNHConnectionHttpCodeErrorKey = @"MSNHConnectionHttpCode";

NS_ASSUME_NONNULL_END

#endif
