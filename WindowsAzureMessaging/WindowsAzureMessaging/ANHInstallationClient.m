//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHInstallationClient+Private.h"
#import "ANHHttpClient.h"
#import "ANHTokenProvider.h"
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif

@implementation ANHInstallationClient

- (id)initWithConnectionString:(ANHConnection *)connectionString hubName:(NSString *)hubName {
    if ((self = [super init]) != nil) {
        _connectionString = connectionString;
        _hubName = hubName;
        _httpClient = [ANHHttpClient new];
        _tokenProvider = [[ANHTokenProvider alloc] initWithConnectionString:connectionString];
    }
    
    return self;
}

- (void)getInstallation:(NSString *)installationId completion:(nonnull ANHInstallationCompletionHandler)completion {
    NSString *endpoint = [_connectionString.serviceEndPoint absoluteString];
    NSString *url =
        [NSString stringWithFormat:@"%@%@/installations/%@?api-version=%@", endpoint, _hubName, installationId, kANHAPIVersion];

    NSString *sasToken = [_tokenProvider generateSharedAccessTokenWithUrl:url];
    NSURL *requestUrl = [NSURL URLWithString:url];

    NSString *sdkVersion = [NSString stringWithUTF8String:NH_C_VERSION];

    NSString *userAgent = [NSString stringWithFormat:kANHUserAgentFormat, kANHAPIVersion, sdkVersion, self.osName, self.osVersion];

    NSDictionary *headers =
        @{@"Content-Type" : @"application/json", @"x-ms-version" : kANHAPIVersion, @"Authorization" : sasToken, @"User-Agent" : userAgent};
    
    [_httpClient
        sendAsync:requestUrl
        method:@"GET"
        headers:headers
        data:nil
        completionHandler:^(NSData *responseBody, __unused NSHTTPURLResponse *response, NSError *error) {
        
            NSError *jsonError = nil;
            id responseJSON = [NSJSONSerialization JSONObjectWithData:responseBody options:NSJSONReadingMutableContainers error:&jsonError];
            if (jsonError) {
                completion(nil, jsonError);
                return;
            }
        
            completion([ANHInstallation createFromJSON:responseJSON], error);
        }];
}

- (void)deleteInstallation:(NSString *)installationId completion:(nonnull ANHCompletionHandler)completion {
    
    NSString *endpoint = [_connectionString.serviceEndPoint absoluteString];
    NSString *url =
        [NSString stringWithFormat:@"%@%@/installations/%@?api-version=%@", endpoint, _hubName, installationId, kANHAPIVersion];

    NSString *sasToken = [_tokenProvider generateSharedAccessTokenWithUrl:url];
    NSURL *requestUrl = [NSURL URLWithString:url];

    NSString *sdkVersion = [NSString stringWithUTF8String:NH_C_VERSION];

    NSString *userAgent = [NSString stringWithFormat:kANHUserAgentFormat, kANHAPIVersion, sdkVersion, self.osName, self.osVersion];

    NSDictionary *headers =
        @{@"Content-Type" : @"application/json", @"x-ms-version" : kANHAPIVersion, @"Authorization" : sasToken, @"User-Agent" : userAgent};
    
    [_httpClient
        sendAsync:requestUrl
        method:@"DELETE"
        headers:headers
        data:nil
        completionHandler:^(__unused NSData *responseBody, __unused NSHTTPURLResponse *response, NSError *error) {
            completion(error);
        }];
}

- (void)upsertInstallation:(ANHInstallation *)installation completion:(nonnull ANHCompletionHandler)completion {
    NSString *url = [self requestURLWithInstallationId:installation.installationId];

    NSString *sasToken = [_tokenProvider generateSharedAccessTokenWithUrl:url];
    NSURL *requestUrl = [NSURL URLWithString:url];

    NSDictionary *headers = [self requestHeadersWithSasToken:sasToken];

    NSData *payload = [installation toJSON];

    [_httpClient
        sendAsync:requestUrl
        method:@"PUT"
        headers:headers
        data:payload
        completionHandler:^(__unused NSData *responseBody, __unused NSHTTPURLResponse *response, NSError *error) {
            completion(error);
        }];
}

- (void)patchInstallation:(NSString *)installationId patches:(NSArray *)patches completion:(nonnull ANHCompletionHandler)completion {
    NSString *url = [self requestURLWithInstallationId:installationId];

    NSString *sasToken = [_tokenProvider generateSharedAccessTokenWithUrl:url];
    NSURL *requestUrl = [NSURL URLWithString:url];

    NSDictionary *headers = [self requestHeadersWithSasToken:sasToken];
    
    NSError *jsonError;
    NSData *payload = [NSJSONSerialization dataWithJSONObject:patches
                                                      options:NSJSONWritingPrettyPrinted
                                                        error:&jsonError];
    if (jsonError) {
        completion(jsonError);
        return;
    }
    
    [_httpClient
        sendAsync:requestUrl
        method:@"PATCH"
        headers:headers
        data:payload
        completionHandler:^(__unused NSData *responseBody, __unused NSHTTPURLResponse *response, NSError *error) {
            completion(error);
        }];
}

- (NSString *)requestURLWithInstallationId:(NSString *)installationId {
    NSString *endpoint = [_connectionString.serviceEndPoint absoluteString];
    return
        [NSString stringWithFormat:@"%@%@/installations/%@?api-version=%@", endpoint, _hubName, installationId, kANHAPIVersion];
}

- (NSDictionary *)requestHeadersWithSasToken:(NSString *)sasToken {
    NSString *sdkVersion = [NSString stringWithUTF8String:NH_C_VERSION];
    NSString *userAgent = [NSString stringWithFormat:kANHUserAgentFormat, kANHAPIVersion, sdkVersion, self.osName, self.osVersion];
    return @{@"Content-Type" : @"application/json", @"x-ms-version" : kANHAPIVersion, @"Authorization" : sasToken, @"User-Agent" : userAgent};
}

- (NSString *)getOSName {
#if TARGET_OS_OSX
    return @"macOS";
#else
    return [[UIDevice currentDevice] systemName];
#endif
}

- (NSString *)getOSVersion {
#if TARGET_OS_OSX
    return [[NSProcessInfo processInfo] operatingSystemVersionString];
#else
    return [[UIDevice currentDevice] systemVersion];
#endif
}

- (void)setDefaultExpiration:(ANHInstallation *)installation {
    if (installation.expirationTime) {
        return;
    }

    NSTimeInterval expirationInSeconds = 60L * 60L * 24L * 90L;
    installation.expirationTime = [[NSDate date] dateByAddingTimeInterval:expirationInSeconds];
}

@end
