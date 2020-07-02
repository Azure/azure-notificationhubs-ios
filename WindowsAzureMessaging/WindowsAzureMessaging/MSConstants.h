//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

// User agent format
static NSString *const kUserAgentFormat = @"NOTIFICATIONHUBS/%@(api-origin=IosSdkV%@; os=%@; os_version=%@;)";

/**
 * Azure Environments
 */
typedef NSString *AzureEnvironment NS_STRING_ENUM;

static AzureEnvironment const AzureEnvironmentINT7 = @"int7.windows-int.net";
static AzureEnvironment const AzureEnvironmentPROD = @"windows.net";
static AzureEnvironment const AzureEnvironmentFFPROD = @"cloudapi.de";
static AzureEnvironment const AzureEnvironmentBFPROD = @"usgovcloudapi.net";
static AzureEnvironment const AzureEnvironmentCHPROD = @"chinacloudapi.cn";

/**
 * Api versions
 */
typedef NSString *ApiVersion NS_STRING_ENUM;

static ApiVersion const ApiVersion2020_06 = @"2020-06";
static ApiVersion const ApiVersion2017_04 = @"2017-04";
