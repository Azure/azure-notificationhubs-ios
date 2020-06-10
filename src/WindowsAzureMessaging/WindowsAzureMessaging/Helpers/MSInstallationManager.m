//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallationManager.h"
#import "MSHttpClient.h"
#import "MSInstallation.h"
#import "MSInstallationManagerPrivate.h"
#import "MSLocalStorage.h"
#import "MSNotificationHub.h"
#import "MSTokenProvider.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// TODO: Move to loading from constants file
NSString *const kUserAgentFormat = @"NOTIFICATIONHUBS/%@(api-origin=IosSdkV%@; os=%@; os_version=%@;)";
NSString *const kAPIVersion = @"2017-04";

@implementation MSInstallationManager

- (instancetype)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName {
    if (self = [super init]) {
        _connectionDictionary = [MSInstallationManager parseConnectionString:connectionString];
        _tokenProvider = [MSTokenProvider createFromConnectionDictionary:_connectionDictionary];
        _httpClient = [MSHttpClient new];
        _connectionString = connectionString;
        _hubName = hubName;
    }

    return self;
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
        [NSString stringWithFormat:@"%@%@/installations/%@?api-version=%@", endpoint, _hubName, installation.installationID, kAPIVersion];

    NSString *sasToken = [_tokenProvider generateSharedAccessTokenWithUrl:url];
    NSURL *requestUrl = [NSURL URLWithString:url];

    // TODO: come up with a way to handle this and work with SPM (seems xcconfig values don't get pulled into SPM)
    //NSString *sdkVersion = [NSString stringWithUTF8String:SDK_VERSION];
    NSString *sdkVersion = @"3.0.0-preview2";

    NSString *userAgent = [NSString stringWithFormat:kUserAgentFormat, kAPIVersion, sdkVersion, [[UIDevice currentDevice] systemName],
                                                     [[UIDevice currentDevice] systemVersion]];

    NSDictionary *headers =
        @{@"Content-Type" : @"application/json", @"x-ms-version" : @"2015-01", @"Authorization" : sasToken, @"User-Agent" : userAgent};

    NSData *payload = [installation toJsonData];

    [_httpClient sendAsync:requestUrl
                    method:@"PUT"
                   headers:headers
                      data:payload
         completionHandler:^(NSData *responseBody, NSHTTPURLResponse *response, NSError *error) {
           completionHandler(error);
         }];
}

+ (NSDictionary *)parseConnectionString:(NSString *)connectionString {
    NSArray *allField = [connectionString componentsSeparatedByString:@";"];

    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    NSString *previousLeft = @"";
    for (int i = 0; i < [allField count]; i++) {
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

        NSString *keyName = [[keyValuePairs objectAtIndex:0] lowercaseString];

        NSString *keyValue = [currentField substringFromIndex:([keyName length] + 1)];
        if ([keyName isEqualToString:@"endpoint"]) {
            keyValue = [[MSInstallationManager fixupEndpoint:[NSURL URLWithString:keyValue] scheme:@"https"] absoluteString];
        }

        [result setObject:keyValue forKey:keyName];
    }

    return result;
}

+ (NSURL *)fixupEndpoint:(NSURL *)endPoint scheme:(NSString *)scheme {
    NSString *modifiedEndpoint = [NSString stringWithString:[endPoint absoluteString]];

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
