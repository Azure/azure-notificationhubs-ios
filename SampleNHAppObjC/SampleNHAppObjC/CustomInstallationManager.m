#import "CustomInstallationManager.h"
#import "CustomTokenProvider.h"

static NSString *const kAPIVersion = @"2020-06";

@interface CustomInstallationManager()

@property(nonatomic, copy) NSString *connectionString;
@property(nonatomic, copy) NSString *hubName;
@property(nonatomic, strong) CustomTokenProvider *tokenProvider;
@property(nonatomic, strong) NSDictionary *connectionDictionary;

@end

@interface MSInstallation()

@property(nonatomic, copy) NSDictionary<NSString *, MSInstallationTemplate *> *templates;
@property(nonatomic, copy) NSSet<NSString *> *tags;

@end

@implementation CustomInstallationManager

- (instancetype)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName {
    if ((self = [super init]) != nil) {
        _connectionDictionary = [CustomInstallationManager parseConnectionString:connectionString];
        _tokenProvider = [[CustomTokenProvider alloc] initWithConnectionDictionary:_connectionDictionary];
        _connectionString = connectionString;
        _hubName = hubName;
    }

    return self;
}

- (void)getInstallation:(NSString *)installationId completionHandler:(InstallationGetCompletionHandler)completionHandler
{
    if (!_tokenProvider) {
        NSString *msg = @"Invalid connection string";
        completionHandler(nil, [NSError errorWithDomain:@"WindowsAzureMessaging" code:-1 userInfo:@{@"Error" : msg}]);
        return;
    }
    
    NSString *endpoint = [_connectionDictionary objectForKey:@"endpoint"];
    NSString *url =
        [NSString stringWithFormat:@"%@%@/installations/%@?api-version=%@", endpoint, _hubName, installationId, kAPIVersion];

    NSString *sasToken = [_tokenProvider generateSharedAccessTokenWithUrl:url];
    NSURL *requestUrl = [NSURL URLWithString:url];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:kAPIVersion forHTTPHeaderField:@"x-ms-version"];
    [request setValue:@"Authorization" forHTTPHeaderField:sasToken];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *err) {

        if (err != nil) {
            completionHandler(nil, err);
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {

            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

            if (statusCode != 200 && statusCode != 404) {
                NSString *responseMessage = [NSString stringWithFormat:@"Error saving to backend: %@", [NSString stringWithFormat:@"%ld", statusCode]];
                completionHandler(nil, [NSError errorWithDomain:@"WindowsAzureMessaging" code:-1 userInfo:@{@"Error" : responseMessage}]);
            } else {
                
                if (statusCode == 404) {
                    completionHandler([MSInstallation new], nil);
                    return;
                }
                       
                NSError *jsonError;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                if (jsonError) {
                    completionHandler(nil, jsonError);
                }
                
                MSInstallation *installation = [CustomInstallationManager createInstallationFromJSON:jsonResponse];
                completionHandler(installation, nil);
            }
        }
    }];

    [dataTask resume];
}

- (void)saveInstallation:(MSInstallation *)installation completionHandler:(InstallationCompletionHandler)completionHandler
{
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

    NSError *error;
    NSData *payload = [installation toJsonData];
    
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
    if (error) {
        completionHandler(error);
        return;
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:kAPIVersion forHTTPHeaderField:@"x-ms-version"];
    [request setValue:@"Authorization" forHTTPHeaderField:sasToken];
    [request setHTTPBody:requestBody];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *err) {

        if (err) {
            completionHandler(err);
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {

            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

            if (statusCode != 200) {
                NSString *responseMessage = [NSString stringWithFormat:@"Error saving to backend: %@", [NSString stringWithFormat:@"%ld", statusCode]];
                completionHandler([NSError errorWithDomain:@"WindowsAzureMessaging" code:-1 userInfo:@{@"Error" : responseMessage}]);
            } else {
                completionHandler(nil);
            }
        }
    }];

    [dataTask resume];
}

- (void)patchInstallation:(NSArray *)patchOperations forInstallationId:(NSString *)installationId completionHandler:(InstallationCompletionHandler)completionHandler {
    if (!_tokenProvider) {
        NSString *msg = @"Invalid connection string";
        completionHandler([NSError errorWithDomain:@"WindowsAzureMessaging" code:-1 userInfo:@{@"Error" : msg}]);
        return;
    }
    
    NSString *endpoint = [_connectionDictionary objectForKey:@"endpoint"];
    NSString *url =
        [NSString stringWithFormat:@"%@%@/installations/%@?api-version=%@", endpoint, _hubName, installationId, kAPIVersion];

    NSString *sasToken = [_tokenProvider generateSharedAccessTokenWithUrl:url];
    NSURL *requestUrl = [NSURL URLWithString:url];
    
    NSError *error;
    
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:patchOperations options:0 error:&error];
    if (error) {
        completionHandler(error);
        return;
    }
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    [request setHTTPMethod:@"PATCH"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:kAPIVersion forHTTPHeaderField:@"x-ms-version"];
    [request setValue:@"Authorization" forHTTPHeaderField:sasToken];
    [request setHTTPBody:requestBody];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *err) {

        if (err) {
            completionHandler(err);
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {

            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

            if (statusCode != 200) {
                NSString *responseMessage = [NSString stringWithFormat:@"Error saving to backend: %@", [NSString stringWithFormat:@"%ld", statusCode]];
                completionHandler([NSError errorWithDomain:@"WindowsAzureMessaging" code:-1 userInfo:@{@"Error" : responseMessage}]);
            } else {
                completionHandler(nil);
            }
        }
    }];

    [dataTask resume];
}

#pragma mark - Helpers

+ (MSInstallation *)createInstallationFromJSON:(NSDictionary *)json {
    MSInstallation *installation = [MSInstallation new];

    installation.installationId = json[@"installationId"];
    installation.pushChannel = json[@"pushChannel"];
    installation.tags = json[@"tags"];
    installation.userId = json[@"userId"];
    installation.templates = json[@"templates"];
    
    NSString *expiration = json[@"expirationTime"];
    if (expiration) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mmZ"];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        
        installation.expirationTime = [dateFormatter dateFromString:expiration];
    }
    
    installation.isDirty = NO;

    return installation;
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
            keyValue = [[CustomInstallationManager fixupEndpoint:[NSURL URLWithString:keyValue] scheme:@"https"] absoluteString];
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
