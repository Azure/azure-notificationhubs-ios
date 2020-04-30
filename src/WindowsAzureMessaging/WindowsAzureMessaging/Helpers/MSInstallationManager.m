// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "MSInstallation.h"
#import "MSInstallationManager.h"
#import "MSHttpClient.h"
#import "MSTokenProvider.h"
#import "MSLocalStorage.h"

@implementation MSInstallationManager

- (MSInstallationManager *) initWithConnectionString:(NSString *)connectionString withHubName:(NSString *)hubName {
    self = [super init];
    
    _connectionDictionary = [self parseConnectionString:connectionString];
    _hubName = hubName;
    _tokenProvider = [[MSTokenProvider alloc] initWithConnectionDictionary:_connectionDictionary];

    return self;
}


- (MSInstallation *) getInstallation: (NSString *) pushToken {
    MSInstallation *installation = [MSLocalStorage loadInstallationFromLocalStorage];
    
    return installation;
}

- (void) upsertInstallationWithDeviceToken: (NSString *) deviceToken {
    
    MSInstallation *installation = [MSLocalStorage loadInstallationFromLocalStorage];
    
    if (!installation) {
        installation = [[MSInstallation alloc] init];
        installation.installationID = [[NSUUID UUID] UUIDString];
        installation.platform = @"APNS";
        installation.pushChannel = deviceToken;
    }
    
    NSString *endpoint = [_connectionDictionary objectForKey:@"endpoint"];
    NSString *url = [NSString stringWithFormat:@"%@%@/installations/%@?api-version=2017-04", endpoint, _hubName, installation.installationID];

    NSString *sasToken = [_tokenProvider generateSharedAccessTokenWithUrl:url];
    NSURL *requestUrl = [NSURL URLWithString:url];
    
    NSDictionary *headers = @{
       @"Content-Type" : @"application/json",
       @"x-ms-version" : @"2015-01",
       @"Authorization" : sasToken
    };
    
    MSHttpClient *httpClient = [MSHttpClient new];

    NSData *payload = [installation toJsonData];
    
    [httpClient sendAsync:requestUrl
                method:@"PUT"
                headers:headers
                data:payload
                completionHandler:^(NSData *responseBody, NSHTTPURLResponse *response, NSError *error) {
        if (!error) {
            NSLog(@"Error via creating installation");
        }
        
        [httpClient sendAsync:requestUrl method:@"GET" headers:headers data:nil completionHandler:^(NSData * _Nullable responseBody, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {
            NSString *str = [[NSString alloc] initWithData:responseBody encoding:NSUTF8StringEncoding];
            [installation updateWithJson:str];
            [MSLocalStorage saveInstallation: installation];
        }];
    }];
}

- (NSDictionary*) parseConnectionString:(NSString*) connectionString
{
    NSArray *allField = [connectionString componentsSeparatedByString:@";"];
    
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    
    NSString* previousLeft = @"";
    for (int i=0; i< [allField count]; i++) {
        NSString* currentField = (NSString*)[allField objectAtIndex:i];
        
        if( (i+1) < [allField count])
        {
            // if next field does not start with known name, this ';' will be ignored
            NSString* lowerCaseNextField = [(NSString*)[allField objectAtIndex:(i+1)] lowercaseString];
            if(!([lowerCaseNextField hasPrefix:@"endpoint="] ||
                 [lowerCaseNextField hasPrefix:@"sharedaccesskeyname="] ||
                 [lowerCaseNextField hasPrefix:@"sharedaccesskey="] ||
                 [lowerCaseNextField hasPrefix:@"sharedsecretissuer="] ||
                 [lowerCaseNextField hasPrefix:@"sharedsecretvalue="] ||
                 [lowerCaseNextField hasPrefix:@"stsendpoint="] ))
            {
                previousLeft = [NSString stringWithFormat:@"%@%@;",previousLeft,currentField];
                continue;
            }
        }
        
        currentField = [NSString stringWithFormat:@"%@%@",previousLeft,currentField];
        previousLeft = @"";
        
        NSArray *keyValuePairs = [currentField componentsSeparatedByString:@"="];
        if([keyValuePairs count] < 2)
        {
            break;
        }
        
        NSString* keyName = [[keyValuePairs objectAtIndex: 0] lowercaseString];
        
        NSString* keyValue = [currentField substringFromIndex:([keyName length] +1)];
        if([keyName isEqualToString:@"endpoint"]){
            {
                keyValue = [[self modifyEndpoint:[NSURL URLWithString:keyValue] scheme:@"https"] absoluteString];
            }
        }
        
        [result setObject:keyValue forKey:keyName];
    }
    
    return result;
}

- (NSURL*) modifyEndpoint:(NSURL*)endPoint scheme:(NSString*)scheme
{
    NSString* modifiedEndpoint = [NSString stringWithString:[endPoint absoluteString]];
    
    if(![modifiedEndpoint hasSuffix:@"/"])
    {
        modifiedEndpoint = [NSString stringWithFormat:@"%@/",modifiedEndpoint];
    }
    
    NSInteger position = [modifiedEndpoint rangeOfString:@":"].location;
    if( position == NSNotFound)
    {
        modifiedEndpoint = [scheme stringByAppendingFormat:@"://%@",modifiedEndpoint];
    }
    else
    {
        modifiedEndpoint = [scheme stringByAppendingFormat:@"%@",[modifiedEndpoint substringFromIndex:position]];
    }
    
    return [NSURL URLWithString:modifiedEndpoint];
}

@end
