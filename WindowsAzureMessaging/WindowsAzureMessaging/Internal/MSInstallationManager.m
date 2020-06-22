//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallationManager.h"
#import "MSInstallationManager+Private.h"
#import "MSHttpClient.h"
#import "MSInstallation.h"
#import "MSLocalStorage.h"
#import "MSNotificationHub.h"
#import "MSTokenProvider.h"
#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif

static NSString *const kUserAgentFormat = @"NOTIFICATIONHUBS/%@(api-origin=IosSdkV%@; os=%@; os_version=%@;)";
static NSString *const kAPIVersion = @"2017-04";

@implementation MSInstallationManager

- (instancetype)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName {
    if ((self = [super init]) != nil) {
        self.connectionDictionary = [MSInstallationManager parseConnectionString:connectionString];
        self.tokenProvider = [MSTokenProvider createFromConnectionDictionary:_connectionDictionary];
        self.httpClient = [MSHttpClient new];
        self.connectionString = connectionString;
        self.hubName = hubName;
    }

    return self;
}

- (NSString *)getOsName {
#if TARGET_OS_OSX
    return @"Mac OSX";
#else
    return [[UIDevice currentDevice] systemName];
#endif
}

- (NSString *)getOsVersion {
#if TARGET_OS_OSX
    return [[NSProcessInfo processInfo] operatingSystemVersionString];
#else
    return [[UIDevice currentDevice] systemVersion];
#endif
}

- (void)setHttpClient:(MSHttpClient *)httpClient {
    _httpClient = httpClient;
}

- (void)saveInstallation:(MSInstallation *)installation
    withEnrichmentHandler:(InstallationEnrichmentHandler)enrichmentHandler
    withManagementHandler:(InstallationManagementHandler)managementHandler
        completionHandler:(InstallationCompletionHandler)completionHandler {
    enrichmentHandler();

    if (managementHandler(completionHandler)) {
        return;
    }

    if (!self.tokenProvider) {
        NSString *msg = @"Invalid connection string";
        completionHandler([NSError errorWithDomain:@"WindowsAzureMessaging" code:-1 userInfo:@{@"Error" : msg}]);
        return;
    }

    if (!installation.pushChannel) {
        NSString *msg = @"You have to setup Push Channel before save installation";
        completionHandler([NSError errorWithDomain:@"WindowsAzureMessaging" code:-1 userInfo:@{@"Error" : msg}]);
        return;
    }

    NSString *endpoint = [self.connectionDictionary objectForKey:@"endpoint"];
    NSString *url =
    [NSString stringWithFormat:@"%@%@/installations/%@?api-version=%@", endpoint, self.hubName, installation.installationID, kAPIVersion];

    NSString *sasToken = [self.tokenProvider generateSharedAccessTokenWithUrl:url];
    NSURL *requestUrl = [NSURL URLWithString:url];

    NSString *sdkVersion = [NSString stringWithUTF8String:NH_C_VERSION];

    NSString *userAgent = [NSString stringWithFormat:kUserAgentFormat, kAPIVersion, sdkVersion, [self getOsName], [self getOsVersion]];

    NSDictionary *headers =
        @{@"Content-Type" : @"application/json", @"x-ms-version" : @"2015-01", @"Authorization" : sasToken, @"User-Agent" : userAgent};

    NSData *payload = [installation toJsonData];

    [self.httpClient sendAsync:requestUrl
                    method:@"PUT"
                   headers:headers
                      data:payload
         completionHandler:^(NSData *responseBody __unused, NSHTTPURLResponse *response __unused, NSError *error) {
           completionHandler(error);
         }];
}

+ (NSDictionary *)parseConnectionString:(NSString *)connectionString {
    NSArray *allField = [connectionString componentsSeparatedByString:@";"];

    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    NSString *previousLeft = @"";
    for (unsigned long i = 0; i < [allField count]; i++) {
        NSString *currentField = (NSString *)[allField objectAtIndex:i];

        if ((i + 1) < [allField count]) {
            // if next field does not start with known name, this ';' will be ignored
            NSString *lowerCaseNextField = [(NSString *)[allField objectAtIndex:(i + 1)] lowercaseString];
            if (!([lowerCaseNextField hasPrefix:@"endpoint="] || [lowerCaseNextField hasPrefix:@"sharedaccesskeyname="] ||
                  [lowerCaseNextField hasPrefix:@"sharedaccesskey="] || [lowerCaseNextField hasPrefix:@"sharedsecretissuer="] ||
                  [lowerCaseNextField hasPrefix:@"sharedsecretvalue="] || [lowerCaseNextField hasPrefix:@"stsendpoint="])) {
                previousLeft = [NSString stringWithFormat:@"%@%@;", previousLeft, currentField];
                continue;
            }
        }

        currentField = [NSString stringWithFormat:@"%@%@", previousLeft, currentField];
        previousLeft = @"";

        NSArray *keyValuePairs = [currentField componentsSeparatedByString:@"="];
        if ([keyValuePairs count] < 2) {
            break;
        }

        NSString *keyName = [(NSString *)[keyValuePairs objectAtIndex:0] lowercaseString];

        NSString *keyValue = [currentField substringFromIndex:([keyName length] + 1)];
        if ([keyName isEqualToString:@"endpoint"]) {
            keyValue = [[MSInstallationManager fixupEndpoint:[NSURL URLWithString:keyValue] scheme:@"https"] absoluteString];
        }

        [result setObject:keyValue forKey:keyName];
    }

    return result;
}

+ (NSURL *)fixupEndpoint:(NSURL *)endPoint scheme:(NSString *)scheme {
    NSString *urlAbsoluteString = [endPoint absoluteString];
    NSString *modifiedEndpoint = [NSString stringWithString:urlAbsoluteString];

    if (![modifiedEndpoint hasSuffix:@"/"]) {
        modifiedEndpoint = [NSString stringWithFormat:@"%@/", modifiedEndpoint];
    }

    NSInteger position = [modifiedEndpoint rangeOfString:@":"].location;
    if (position == NSNotFound) {
        modifiedEndpoint = [scheme stringByAppendingFormat:@"://%@", modifiedEndpoint];
    } else {
        modifiedEndpoint = [scheme stringByAppendingFormat:@"%@", [modifiedEndpoint substringFromIndex:position]];
    }

    return [NSURL URLWithString:modifiedEndpoint];
}

@end
