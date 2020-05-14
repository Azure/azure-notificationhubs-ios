//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef MS_ERRORS_H
#define MS_ERRORS_H

#import <Foundation/Foundation.h>

#define MS_NOTIFICATION_HUB_BASE_DOMAIN @"com.Microsoft.AzureNotificationHubs."

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Domain

static NSString *const kMSNHErrorDomain = MS_NOTIFICATION_HUB_BASE_DOMAIN @"ErrorDomain";

#pragma mark - General

// Error codes.
NS_ENUM(NSInteger){MSNHCanceledErrorCode = 1, MSNHDisabledErrorCode = 2};

// Error descriptions.
static NSString const *kMSNHCanceledErrorDesc = @"The operation was canceled.";
static NSString const *kMSNHDisabledErrorDesc = @"The service is disabled.";

NS_ASSUME_NONNULL_END

#endif
