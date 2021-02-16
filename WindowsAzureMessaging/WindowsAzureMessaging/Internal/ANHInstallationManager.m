//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHInstallationManager.h"
#import "ANHHttpClient.h"
#import "ANHInstallation.h"
#import "ANHInstallationManager+Private.h"
#import "ANHLocalStorage.h"
#import "ANHNotificationHub.h"
#import "ANHTokenProvider.h"
#import <Foundation/Foundation.h>
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif

static NSString *const kUserAgentFormat = @"NOTIFICATIONHUBS/%@(api-origin=IosSdkV%@; os=%@; os_version=%@;)";
static NSString *const kAPIVersion = @"2020-06";

@implementation ANHInstallationManager

- (instancetype)init {
    if ((self = [super init]) != nil) {
    }

    return self;
}

- (instancetype)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName {
    if ((self = [super init]) != nil) {
        _connectionDictionary = [ANHInstallationManager parseConnectionString:connectionString];
        _tokenProvider = [ANHTokenProvider createFromConnectionDictionary:_connectionDictionary];
        _httpClient = [ANHHttpClient new];
        _connectionString = connectionString;
        _hubName = hubName;
    }

    return self;
}

- (NSString *)getOsName {
#if TARGET_OS_OSX
    return @"macOS";
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

- (void)setExpiration:(ANHInstallation *)installation {
    if (installation.expirationTime != nil) {
        return;
    }

    NSTimeInterval expirationInSeconds = 60L * 60L * 24L * 90L;
    installation.expirationTime = [[NSDate date] dateByAddingTimeInterval:expirationInSeconds];
}

- (void)setHttpClient:(ANHHttpClient *)httpClient {
    _httpClient = httpClient;
}

- (void)saveInstallation:(ANHInstallation *)installation
    withEnrichmentHandler:(InstallationEnrichmentHandler)enrichmentHandler
    withManagementHandler:(InstallationManagementHandler)managementHandler
        completionHandler:(InstallationCompletionHandler)completionHandler {
    enrichmentHandler();

    [self setExpiration:installation];

    if (managementHandler(completionHandler)) {
        return;
    }

    if (!_tokenProvider) {
        NSString *msg = @"Invalid connection string";
        completionHandler([NSError errorWithDomain:@"WindowsAzureMessaging" code:-1 userInfo:@{@"Error" : msg}]);
        return;
    }

    if (!installation.pushChannel) {
        NSString *msg = @"You have to setup Push Channel before save installation";
        completionHandler([NSError errorWithDomain:@"WindowsAzureMessaging" code:-1 userInfo:@{@"Error" : msg}]);
        return;
    }

    NSString *endpoint = [_connectionDictionary objectForKey:@"endpoint"];
    NSString *url =
        [NSString stringWithFormat:@"%@%@/installations/%@?api-version=%@", endpoint, _hubName, installation.installationId, kAPIVersion];

    NSString *sasToken = [_tokenProvider generateSharedAccessTokenWithUrl:url];
    NSURL *requestUrl = [NSURL URLWithString:url];

    NSString *sdkVersion = [NSString stringWithUTF8String:NH_C_VERSION];

    NSString *userAgent = [NSString stringWithFormat:kUserAgentFormat, kAPIVersion, sdkVersion, [self getOsName], [self getOsVersion]];

    NSDictionary *headers =
        @{@"Content-Type" : @"application/json", @"x-ms-version" : kAPIVersion, @"Authorization" : sasToken, @"User-Agent" : userAgent};

    NSData *payload = [installation toJsonData];

    [_httpClient sendAsync:requestUrl
                    method:@"PUT"
                   headers:headers
                      data:payload
         completionHandler:^(__unused NSData *responseBody, __unused NSHTTPURLResponse *response, NSError *error) {
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
            keyValue = [[ANHInstallationManager fixupEndpoint:[NSURL URLWithString:keyValue] scheme:@"https"] absoluteString];
        }

        [result setObject:keyValue forKey:keyName];
    }

    return result;
}

+ (NSURL *)fixupEndpoint:(NSURL *)endPoint scheme:(NSString *)scheme {
    NSString *absoluteString = [endPoint absoluteString];
    NSString *modifiedEndpoint = [NSString stringWithString:absoluteString];

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
