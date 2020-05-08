//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallationManager.h"
#import "MSHttpClient.h"
#import "MSInstallation.h"
#import "MSLocalStorage.h"
#import "MSTokenProvider.h"
#import <Foundation/Foundation.h>

// Singleton
static MSInstallationManager *sharedInstance = nil;
static dispatch_once_t onceToken;

static NSString *_connectionString;
static NSString *_hubName;

@implementation MSInstallationManager

- (instancetype)init {
    if (self = [super init]) {
        connectionDictionary = [MSInstallationManager parseConnectionString:_connectionString];
        tokenProvider = [MSTokenProvider createFromConnectionDictionary:connectionDictionary];
        _httpClient = [MSHttpClient new];
    }

    return self;
}

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
      if (sharedInstance == nil) {
          sharedInstance = [self new];
      }
    });
    return sharedInstance;
}

+ (void)resetInstance {
    sharedInstance = nil;
    onceToken = 0;
}

+ (void)setHttpClient:(MSHttpClient *)client {
    [MSInstallationManager sharedInstance].httpClient = client;
}

+ (void)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName {
    _connectionString = connectionString;
    _hubName = hubName;
}

+ (void)setPushChannel:(NSString *)pushChannel {
    MSInstallation *installation = [MSLocalStorage loadInstallation];

    installation.pushChannel = pushChannel;

    [MSLocalStorage upsertInstallation:installation];
}

+ (MSInstallation *)getInstallation {
    MSInstallation *installation = [MSLocalStorage loadInstallation];

    return installation;
}

+ (BOOL)addTags:(NSSet<NSString *> *)tags {
    MSInstallation *installation = [MSLocalStorage loadInstallation];

    if ([installation addTags:tags]) {
        [MSLocalStorage upsertInstallation:installation];
        return YES;
    }

    return NO;
}

+ (BOOL)removeTags:(NSSet<NSString *> *)tags {
    MSInstallation *installation = [MSLocalStorage loadInstallation];

    if (installation.tags == nil || [installation.tags count] == 0) {
        return NO;
    }

    [installation removeTags:tags];

    [MSLocalStorage upsertInstallation:installation];

    return YES;
}

+ (void)clearTags {
    MSInstallation *installation = [MSLocalStorage loadInstallation];

    if (installation && installation.tags && [installation.tags count] > 0) {
        [installation clearTags];
        [MSLocalStorage upsertInstallation:installation];
    }
}

+ (NSSet<NSString *> *)getTags {
    MSInstallation *installation = [MSLocalStorage loadInstallation];

    if (!installation) {
        installation = [MSInstallation new];
    }

    return [installation getTags];
}

+ (void)saveInstallation {
    [[MSInstallationManager sharedInstance] saveInstallation];
}

- (void)saveInstallation {

    if (!tokenProvider) {
        NSLog(@"Invalid connection string");
        return;
    }

    MSInstallation *installation = [MSLocalStorage loadInstallation];

    if (!installation.pushChannel) {
        NSLog(@"You have to setup Push Channel before save installation");
        return;
    }

    NSString *endpoint = [connectionDictionary objectForKey:@"endpoint"];
    NSString *url =
        [NSString stringWithFormat:@"%@%@/installations/%@?api-version=2017-04", endpoint, _hubName, installation.installationID];

    NSString *sasToken = [tokenProvider generateSharedAccessTokenWithUrl:url];
    NSURL *requestUrl = [NSURL URLWithString:url];

    NSDictionary *headers = @{@"Content-Type" : @"application/json", @"x-ms-version" : @"2015-01", @"Authorization" : sasToken};

    NSData *payload = [installation toJsonData];

    [_httpClient sendAsync:requestUrl
                    method:@"PUT"
                   headers:headers
                      data:payload
         completionHandler:^(NSData *responseBody, NSHTTPURLResponse *response, NSError *error) {
           if (error) {
               NSLog(@"Error via creating installation: %@", error.localizedDescription);
           } else {
               [MSLocalStorage upsertLastInstallation:installation];
           }
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
            {
                keyValue = [[MSInstallationManager modifyEndpoint:[NSURL URLWithString:keyValue] scheme:@"https"] absoluteString];
            }
        }

        [result setObject:keyValue forKey:keyName];
    }

    return result;
}

+ (NSURL *)modifyEndpoint:(NSURL *)endPoint scheme:(NSString *)scheme {
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
