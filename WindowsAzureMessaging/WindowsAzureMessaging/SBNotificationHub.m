//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "SBNotificationHub.h"
#import "SBLocalStorage.h"
#import "SBNotificationHubHelper.h"
#import "SBRegistration.h"
#import "SBRegistrationParser.h"
#import "SBTemplateRegistration.h"
#import "SBTokenProvider.h"
#import "SBURLConnection.h"
#import <UIKit/UIKit.h>

typedef void (^SBCompletion)(NSError *);

@interface SBThreadParameter : NSObject

@property(copy, nonatomic) NSArray *parameters;
@property(copy, nonatomic) NSString *deviceToken;
@property(copy, nonatomic) SBCompletion completion;
@property(nonatomic) BOOL isMainThread;

@end

@implementation SBThreadParameter
@synthesize parameters, completion, isMainThread, deviceToken;

@end

@implementation SBNotificationHub {
  @private
    NSString *_path;
    NSURL *_serviceEndPoint;
    SBTokenProvider *tokenProvider;
    SBLocalStorage *storageManager;
}

static NSString *const currentVersion = @"v0.1.6";
static NSString *const _APIVersion = @"2013-04";
static NSString *const _UserAgentTemplate = @"NOTIFICATIONHUBS/%@(api-origin=IosSdk; os=%@; os_version=%@;)";

- (SBNotificationHub *)initWithConnectionString:(NSString *)connectionString notificationHubPath:(NSString *)notificationHubPath {
    self = [super init];

    if (!connectionString || !notificationHubPath || connectionString.length == 0 || notificationHubPath.length == 0) {
        NSLog(@"Invalid connection string or notification hub path");
        return nil;
    }

    if (self) {
        NSDictionary *connectionDictionary = [SBNotificationHubHelper parseConnectionString:connectionString];
        if (!connectionDictionary) {
            NSLog(@"Failed to parse connection string");
            return nil;
        }

        NSString *endPoint = [connectionDictionary objectForKey:@"endpoint"];
        if (endPoint && endPoint.length > 0) {
            self->_serviceEndPoint = [[NSURL alloc] initWithString:endPoint];
        }

        if (self->_serviceEndPoint == nil || [self->_serviceEndPoint host] == nil) {
            NSLog(@"Endpoint is missing or not in URL format in connectionString");
            return nil;
        }

        self->_path = [notificationHubPath copy];
        tokenProvider = [[SBTokenProvider alloc] initWithConnectionDictinary:connectionDictionary];

        if (tokenProvider == nil) {
            NSLog(@"Failed to initialize token provider");
            return nil;
        }

        storageManager = [[SBLocalStorage alloc] initWithNotificationHubPath:notificationHubPath];
        if (storageManager == nil) {
            NSLog(@"Failed to initialize storage manager");
            return nil;
        }
    }

    return self;
}

- (NSString *)convertDeviceToken:(NSData *)deviceTokenData {
    if (!deviceTokenData) {
        NSLog(@"Device token data is nil");
        return nil;
    }

    const char *data = [deviceTokenData bytes];
    NSMutableString *newDeviceToken = [NSMutableString stringWithCapacity:[deviceTokenData length] * 2];

    for (NSUInteger i = 0; i < [deviceTokenData length]; i++) {
        [newDeviceToken appendFormat:@"%02.2hhX", data[i]];
    }

    return [newDeviceToken copy];
}

- (void)registerNativeWithDeviceToken:(NSData *)deviceTokenData tags:(NSSet *)tags completion:(void (^)(NSError *error))completion {
    if (!deviceTokenData) {
        if (completion) {
            completion([SBNotificationHubHelper errorForNullDeviceToken]);
        }
        return;
    }

    NSString *deviceToken = [self convertDeviceToken:deviceTokenData];
    if (!deviceToken) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Failed to convert device token" code:-1002]);
        }
        return;
    }

    NSString *name = [SBRegistration Name];
    if (!name) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Failed to get registration name" code:-1003]);
        }
        return;
    }

    NSString *payload = [SBRegistration payloadWithDeviceToken:deviceToken tags:tags];
    if (!payload) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Failed to create payload" code:-1004]);
        }
        return;
    }

    if (storageManager.isRefreshNeeded) {
        NSString *refreshDeviceToken = [self getRefreshDeviceTokenWithNewDeviceToken:deviceToken];
        if (!refreshDeviceToken) {
            if (completion) {
                completion([SBNotificationHubHelper errorWithMsg:@"Failed to get refresh device token" code:-1005]);
            }
            return;
        }

        [self retrieveAllRegistrationsWithDeviceToken:refreshDeviceToken completion:^(NSArray *regs, NSError *error) {
            if (error) {
                if (completion) {
                    completion(error);
                }
                return;
            }

            if (self->storageManager) {
                [self->storageManager refreshFinishedWithDeviceToken:refreshDeviceToken];
                [self createOrUpdateWith:name payload:payload deviceToken:deviceToken completion:completion];
            } else {
                if (completion) {
                    completion([SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006]);
                }
            }
        }];
    } else {
        [self createOrUpdateWith:name payload:payload deviceToken:deviceToken completion:completion];
    }
}

- (void)registerTemplateWithDeviceToken:(NSData *)deviceTokenData
                                   name:(NSString *)name
                       jsonBodyTemplate:(NSString *)bodyTemplate
                         expiryTemplate:(NSString *)expiryTemplate
                                   tags:(NSSet *)tags
                             completion:(void (^)(NSError *error))completion {
    [self registerTemplateWithDeviceToken:deviceTokenData
                                     name:name
                         jsonBodyTemplate:bodyTemplate
                           expiryTemplate:expiryTemplate
                         priorityTemplate:nil
                                     tags:tags
                               completion:completion];
}

- (void)registerTemplateWithDeviceToken:(NSData *)deviceTokenData
                                   name:(NSString *)name
                       jsonBodyTemplate:(NSString *)bodyTemplate
                         expiryTemplate:(NSString *)expiryTemplate
                       priorityTemplate:(NSString *)priorityTemplate
                                   tags:(NSSet *)tags
                             completion:(void (^)(NSError *error))completion {
    if (!deviceTokenData) {
        if (completion) {
            completion([SBNotificationHubHelper errorForNullDeviceToken]);
        }
        return;
    }

    if (!name || name.length == 0) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Template name is nil or empty" code:-1007]);
        }
        return;
    }

    NSString *deviceToken = [self convertDeviceToken:deviceTokenData];
    if (!deviceToken) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Failed to convert device token" code:-1002]);
        }
        return;
    }

    NSError *error;
    if ([self verifyTemplateName:name error:&error] == FALSE) {
        if (completion) {
            completion(error);
        }
        return;
    }

    NSString *payload = [SBTemplateRegistration payloadWithDeviceToken:deviceToken
                                                         bodyTemplate:bodyTemplate
                                                       expiryTemplate:expiryTemplate
                                                     priorityTemplate:priorityTemplate
                                                                 tags:tags
                                                         templateName:name];
    if (!payload) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Failed to create template payload" code:-1008]);
        }
        return;
    }

    if (storageManager.isRefreshNeeded) {
        NSString *refreshDeviceToken = [self getRefreshDeviceTokenWithNewDeviceToken:deviceToken];
        if (!refreshDeviceToken) {
            if (completion) {
                completion([SBNotificationHubHelper errorWithMsg:@"Failed to get refresh device token" code:-1005]);
            }
            return;
        }

        [self retrieveAllRegistrationsWithDeviceToken:refreshDeviceToken completion:^(NSArray *regs, NSError *err) {
            if (err) {
                if (completion) {
                    completion(err);
                }
                return;
            }

            if (self->storageManager) {
                [self->storageManager refreshFinishedWithDeviceToken:refreshDeviceToken];
                [self createOrUpdateWith:name payload:payload deviceToken:deviceToken completion:completion];
            } else {
                if (completion) {
                    completion([SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006]);
                }
            }
        }];
    } else {
        [self createOrUpdateWith:name payload:payload deviceToken:deviceToken completion:completion];
    }
}

- (void)createOrUpdateWith:(NSString *)name
                   payload:(NSString *)payload
               deviceToken:(NSString *)deviceToken
                completion:(void (^)(NSError *))completion {
    if (!name || !payload || !deviceToken) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Invalid parameters for createOrUpdate" code:-1009]);
        }
        return;
    }

    StoredRegistrationEntry *cached = [storageManager getStoredRegistrationEntryWithRegistrationName:name];
    if (!cached) {
        [self createRegistrationIdAndUpsert:name
                                    payload:payload
                                deviceToken:deviceToken
                                 completion:^(NSError *error) {
                                     if (error && [error code] == 410) {
                                         [self createRegistrationIdAndUpsert:name
                                                                     payload:payload
                                                                 deviceToken:deviceToken
                                                                  completion:completion];
                                     } else {
                                         if (completion) {
                                             completion(error);
                                         }
                                     }
                                 }];
    } else {
        if (!cached.RegistrationId) {
            if (completion) {
                completion([SBNotificationHubHelper errorWithMsg:@"Cached registration ID is nil" code:-1010]);
            }
            return;
        }

        [self upsertRegistrationWithName:name
                          registrationId:cached.RegistrationId
                                 payload:payload
                              completion:^(NSError *error) {
                                  if (error && [error code] == 410) {
                                      [self createRegistrationIdAndUpsert:name
                                                                  payload:payload
                                                              deviceToken:deviceToken
                                                               completion:completion];
                                  } else {
                                      if (completion) {
                                          completion(error);
                                      }
                                  }
                              }];
    }
}

- (void)createRegistrationIdAndUpsert:(NSString *)name
                              payload:(NSString *)payload
                          deviceToken:(NSString *)deviceToken
                           completion:(void (^)(NSError *))completion {
    if (!name || !payload || !deviceToken) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Invalid parameters for createRegistrationIdAndUpsert" code:-1011]);
        }
        return;
    }

    NSURL *requestUri = [self composeCreateRegistrationIdUri];
    if (!requestUri) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Failed to compose request URI" code:-1012]);
        }
        return;
    }

    [self registrationOperationWithRequestUri:requestUri
                                      payload:@""
                                   httpMethod:@"POST"
                                         ETag:@""
                                   completion:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
                                       if (error) {
                                           if (completion) {
                                               completion(error);
                                           }
                                           return;
                                       }

                                       if (!response) {
                                           if (completion) {
                                               completion([SBNotificationHubHelper errorWithMsg:@"No response received" code:-1013]);
                                           }
                                           return;
                                       }

                                       NSString *locationField = [[response allHeaderFields] objectForKey:@"Location"];
                                       if (!locationField) {
                                           if (completion) {
                                               completion([SBNotificationHubHelper errorWithMsg:@"No location field in response" code:-1014]);
                                           }
                                           return;
                                       }

                                       NSURL *locationUrl = [[NSURL alloc] initWithString:locationField];
                                       if (!locationUrl) {
                                           if (completion) {
                                               completion([SBNotificationHubHelper errorWithMsg:@"Invalid location URL" code:-1015]);
                                           }
                                           return;
                                       }

                                       NSString *registrationId = [self extractRegistrationIdFromLocationUri:locationUrl];
                                       if (!registrationId) {
                                           if (completion) {
                                               completion([SBNotificationHubHelper errorWithMsg:@"Failed to extract registration ID" code:-1016]);
                                           }
                                           return;
                                       }

                                       if (self->storageManager) {
                                           [self->storageManager updateWithRegistrationName:name
                                                                             registrationId:registrationId
                                                                                       eTag:@"*"
                                                                                deviceToken:deviceToken];
                                           [self upsertRegistrationWithName:name
                                                             registrationId:registrationId
                                                                    payload:payload
                                                                 completion:completion];
                                       } else {
                                           if (completion) {
                                               completion([SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006]);
                                           }
                                       }
                                   }];
}

- (void)upsertRegistrationWithName:(NSString *)name
                    registrationId:(NSString *)registrationId
                           payload:(NSString *)payload
                        completion:(void (^)(NSError *))completion {
    if (!name || !registrationId || !payload) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Invalid parameters for upsertRegistration" code:-1017]);
        }
        return;
    }

    NSURL *requestUri = [self composeRegistrationUriWithRegistrationId:registrationId];
    if (!requestUri) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Failed to compose request URI" code:-1012]);
        }
        return;
    }

    [self registrationOperationWithRequestUri:requestUri
                                      payload:payload
                                   httpMethod:@"PUT"
                                         ETag:@""
                                   completion:^(NSHTTPURLResponse *response1, NSData *data, NSError *error) {
                                       if (!error) {
                                           [self parseResultAndUpdateWithName:name data:data error:&error];
                                       }

                                       if (completion) {
                                           completion(error);
                                       }
                                   }];
}

- (void)parseResultAndUpdateWithName:(NSString *)name data:(NSData *)data error:(NSError *__autoreleasing *)error {
    if (!name || !data) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Invalid parameters for parseResultAndUpdate" code:-1018];
        }
        return;
    }

    NSError *parseError;
    NSArray *registrations = [SBRegistrationParser parseRegistrations:data error:&parseError];
    if (!parseError) {
        if (registrations.count > 0) {
            id registration = [registrations objectAtIndex:0];
            if ([registration isKindOfClass:[SBRegistration class]]) {
                if (storageManager) {
                    [storageManager updateWithRegistrationName:name registration:(SBRegistration *)registration];
                } else {
                    parseError = [SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006];
                }
            } else {
                parseError = [SBNotificationHubHelper errorWithMsg:@"Invalid registration object at index 0" code:-1000];
            }
        } else {
            parseError = [SBNotificationHubHelper errorWithMsg:@"No registrations found in response" code:-1001];
        }
    }

    if (parseError && error) {
        *error = parseError;
    }
}

- (void)retrieveAllRegistrationsWithDeviceToken:(NSString *)deviceToken completion:(void (^)(NSArray *, NSError *))completion {
    if (!deviceToken) {
        if (completion) {
            completion(nil, [SBNotificationHubHelper errorWithMsg:@"Device token is nil" code:-1019]);
        }
        return;
    }

    NSURL *requestUri = [self composeRetrieveAllRegistrationsUriWithDeviceToken:deviceToken];
    if (!requestUri) {
        if (completion) {
            completion(nil, [SBNotificationHubHelper errorWithMsg:@"Failed to compose request URI" code:-1012]);
        }
        return;
    }

    [self registrationOperationWithRequestUri:requestUri
                                      payload:@""
                                   httpMethod:@"GET"
                                         ETag:@""
                                   completion:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
                                       if (error) {
                                           if ([error code] == 404) {
                                               if (completion) {
                                                   completion(nil, nil);
                                               }
                                               return;
                                           } else {
                                               if (completion) {
                                                   completion(nil, error);
                                               }
                                               return;
                                           }
                                       }

                                       if (!data) {
                                           if (completion) {
                                               completion(nil, [SBNotificationHubHelper errorWithMsg:@"No data in response" code:-1020]);
                                           }
                                           return;
                                       }

                                       NSError *parseError;
                                       NSArray *registrations = [SBRegistrationParser parseRegistrations:data error:&parseError];
                                       if (parseError) {
                                           if (completion) {
                                               completion(nil, parseError);
                                           }
                                           return;
                                       }

                                       if (self->storageManager) {
                                           for (SBRegistration *retrieved in registrations) {
                                               if ([retrieved isKindOfClass:[SBRegistration class]]) {
                                                   [self->storageManager updateWithRegistration:retrieved];
                                               }
                                           }
                                           if (completion) {
                                               completion(registrations, nil);
                                           }
                                       } else {
                                           if (completion) {
                                               completion(nil, [SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006]);
                                           }
                                       }
                                   }];
}

- (void)unregisterNativeWithCompletion:(void (^)(NSError *))completion {
    [self deleteRegistrationWithName:[SBRegistration Name] completion:completion];
}

- (void)unregisterTemplateWithName:(NSString *)name completion:(void (^)(NSError *))completion {
    if (!name) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Template name is nil" code:-1007]);
        }
        return;
    }

    NSError *error;
    if ([self verifyTemplateName:name error:&error] == FALSE) {
        if (completion) {
            completion(error);
        }
        return;
    }

    [self deleteRegistrationWithName:name completion:completion];
}

- (void)deleteRegistrationWithName:(NSString *)templateName completion:(void (^)(NSError *))completion {
    if (!templateName) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Template name is nil" code:-1007]);
        }
        return;
    }

    StoredRegistrationEntry *cached = storageManager ? [storageManager getStoredRegistrationEntryWithRegistrationName:templateName] : nil;
    if (!cached) {
        if (completion) {
            completion(nil);
        }
        return;
    }

    if (!cached.RegistrationId) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Cached registration ID is nil" code:-1010]);
        }
        return;
    }

    NSURL *requestUri = [self composeRegistrationUriWithRegistrationId:cached.RegistrationId];
    if (!requestUri) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Failed to compose request URI" code:-1012]);
        }
        return;
    }

    [self registrationOperationWithRequestUri:requestUri
                                      payload:@""
                                   httpMethod:@"DELETE"
                                         ETag:@"*"
                                   completion:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
                                       if (error == nil || [error code] == 404) {
                                           if (self->storageManager) {
                                               [self->storageManager deleteWithRegistrationName:templateName];
                                               error = nil;
                                           } else {
                                               error = [SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006];
                                           }
                                       }

                                       if (completion) {
                                           completion(error);
                                       }
                                   }];
}

- (void)unregisterAllWithDeviceToken:(NSData *)deviceTokenData completion:(void (^)(NSError *))completion {
    if (!deviceTokenData) {
        if (completion) {
            completion([SBNotificationHubHelper errorForNullDeviceToken]);
        }
        return;
    }

    NSString *deviceToken = [self convertDeviceToken:deviceTokenData];
    if (!deviceToken) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Failed to convert device token" code:-1002]);
        }
        return;
    }

    SBThreadParameter *parameter = [[SBThreadParameter alloc] init];
    if (!parameter) {
        if (completion) {
            completion([SBNotificationHubHelper errorWithMsg:@"Failed to create thread parameter" code:-1021]);
        }
        return;
    }

    parameter.deviceToken = deviceToken;
    parameter.completion = completion;
    parameter.isMainThread = [[NSThread currentThread] isMainThread];
    [self performSelectorInBackground:@selector(deleteAllRegistrationThread:) withObject:parameter];
}

- (void)deleteAllRegistrationThread:(SBThreadParameter *)parameter {
    if (!parameter || !parameter.deviceToken) {
        if (parameter.completion) {
            if (parameter.isMainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    parameter.completion([SBNotificationHubHelper errorWithMsg:@"Invalid thread parameter" code:-1022]);
                });
            } else {
                parameter.completion([SBNotificationHubHelper errorWithMsg:@"Invalid thread parameter" code:-1022]);
            }
        }
        return;
    }

    NSError *error;
    NSArray *registrations = [self retrieveAllRegistrationsWithDeviceToken:parameter.deviceToken error:&error];
    if (registrations && registrations.count > 0) {
        for (id reg in registrations) {
            if (![reg isKindOfClass:[SBRegistration class]]) {
                continue;
            }
            NSString *name = [SBNotificationHubHelper nameOfRegistration:reg];
            if (name) {
                [self deleteRegistrationWithName:name error:&error];
                if (error) {
                    break;
                }
            }
        }
    }

    if (!error && storageManager) {
        [storageManager deleteAllRegistrations];
    }

    if (parameter.completion) {
        if (parameter.isMainThread) {
            dispatch_async(dispatch_get_main_queue(), ^{
                parameter.completion(error);
            });
        } else {
            parameter.completion(error);
        }
    }
}

- (BOOL)registerNativeWithDeviceToken:(NSData *)deviceTokenData tags:(NSSet *)tags error:(NSError *__autoreleasing *)error {
    if (!deviceTokenData) {
        if (error) {
            *error = [SBNotificationHubHelper errorForNullDeviceToken];
        }
        return FALSE;
    }

    NSString *deviceToken = [self convertDeviceToken:deviceTokenData];
    if (!deviceToken) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to convert device token" code:-1002];
        }
        return FALSE;
    }

    NSString *name = [SBRegistration Name];
    if (!name) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to get registration name" code:-1003];
        }
        return FALSE;
    }

    NSString *payload = [SBRegistration payloadWithDeviceToken:deviceToken tags:tags];
    if (!payload) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to create payload" code:-1004];
        }
        return FALSE;
    }

    if (storageManager.isRefreshNeeded) {
        NSString *refreshDeviceToken = [self getRefreshDeviceTokenWithNewDeviceToken:deviceToken];
        if (!refreshDeviceToken) {
            if (error) {
                *error = [SBNotificationHubHelper errorWithMsg:@"Failed to get refresh device token" code:-1005];
            }
            return FALSE;
        }

        NSError *retrieveError;
        [self retrieveAllRegistrationsWithDeviceToken:refreshDeviceToken error:&retrieveError];
        if (retrieveError) {
            if (error) {
                *error = retrieveError;
            }
            return FALSE;
        }

        if (storageManager) {
            [storageManager refreshFinishedWithDeviceToken:refreshDeviceToken];
        } else {
            if (error) {
                *error = [SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006];
            }
            return FALSE;
        }
    }

    return [self createorUpdateWith:name payload:payload deviceToken:deviceToken error:error];
}

- (BOOL)registerTemplateWithDeviceToken:(NSData *)deviceTokenData
                                   name:(NSString *)templateName
                       jsonBodyTemplate:(NSString *)bodyTemplate
                         expiryTemplate:(NSString *)expiryTemplate
                                   tags:(NSSet *)tags
                                  error:(NSError *__autoreleasing *)error {
    return [self registerTemplateWithDeviceToken:deviceTokenData
                                            name:templateName
                                jsonBodyTemplate:bodyTemplate
                                  expiryTemplate:expiryTemplate
                                priorityTemplate:nil
                                            tags:tags
                                           error:error];
}

- (BOOL)registerTemplateWithDeviceToken:(NSData *)deviceTokenData
                                   name:(NSString *)templateName
                       jsonBodyTemplate:(NSString *)bodyTemplate
                         expiryTemplate:(NSString *)expiryTemplate
                       priorityTemplate:(NSString *)priorityTemplate
                                   tags:(NSSet *)tags
                                  error:(NSError *__autoreleasing *)error {
    if (!deviceTokenData) {
        if (error) {
            *error = [SBNotificationHubHelper errorForNullDeviceToken];
        }
        return FALSE;
    }

    if (!templateName) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Template name is nil" code:-1007];
        }
        return FALSE;
    }

    NSString *deviceToken = [self convertDeviceToken:deviceTokenData];
    if (!deviceToken) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to convert device token" code:-1002];
        }
        return FALSE;
    }

    if ([self verifyTemplateName:templateName error:error] == FALSE) {
        return FALSE;
    }

    NSString *payload = [SBTemplateRegistration payloadWithDeviceToken:deviceToken
                                                         bodyTemplate:bodyTemplate
                                                       expiryTemplate:expiryTemplate
                                                     priorityTemplate:priorityTemplate
                                                                 tags:tags
                                                         templateName:templateName];
    if (!payload) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to create template payload" code:-1008];
        }
        return FALSE;
    }

    if (storageManager.isRefreshNeeded) {
        NSString *refreshDeviceToken = [self getRefreshDeviceTokenWithNewDeviceToken:deviceToken];
        if (!refreshDeviceToken) {
            if (error) {
                *error = [SBNotificationHubHelper errorWithMsg:@"Failed to get refresh device token" code:-1005];
            }
            return FALSE;
        }

        NSError *retrieveError;
        [self retrieveAllRegistrationsWithDeviceToken:refreshDeviceToken error:&retrieveError];
        if (retrieveError) {
            if (error) {
                *error = retrieveError;
            }
            return FALSE;
        }

        if (storageManager) {
            [storageManager refreshFinishedWithDeviceToken:refreshDeviceToken];
        } else {
            if (error) {
                *error = [SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006];
            }
            return FALSE;
        }
    }

    return [self createorUpdateWith:templateName payload:payload deviceToken:deviceToken error:error];
}

- (BOOL)createorUpdateWith:(NSString *)name
                   payload:(NSString *)payload
               deviceToken:(NSString *)deviceToken
                     error:(NSError *__autoreleasing *)error {
    if (!name || !payload || !deviceToken) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Invalid parameters for createorUpdateWith" code:-1009];
        }
        return FALSE;
    }

    StoredRegistrationEntry *cached = storageManager ? [storageManager getStoredRegistrationEntryWithRegistrationName:name] : nil;
    NSString *registrationId;
    if (!cached) {
        NSError *createRegistrationError;
        registrationId = [self createRegistrationId:&createRegistrationError];
        if (createRegistrationError) {
            if (error) {
                *error = createRegistrationError;
            }
            return FALSE;
        }

        if (!registrationId) {
            if (error) {
                *error = [SBNotificationHubHelper errorWithMsg:@"Failed to create registration ID" code:-1016];
            }
            return FALSE;
        }

        if (storageManager) {
            [storageManager updateWithRegistrationName:name registrationId:registrationId eTag:@"*" deviceToken:deviceToken];
        } else {
            if (error) {
                *error = [SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006];
            }
            return FALSE;
        }
    } else {
        registrationId = cached.RegistrationId;
        if (!registrationId) {
            if (error) {
                *error = [SBNotificationHubHelper errorWithMsg:@"Cached registration ID is nil" code:-1010];
            }
            return FALSE;
        }
    }

    NSError *upsertRegistrationError;
    BOOL result = [self upsertRegistrationWithName:name registrationId:registrationId payload:payload error:&upsertRegistrationError];
    if (upsertRegistrationError && [upsertRegistrationError code] == 410) {
        NSError *retrieveRegistrationError;
        registrationId = [self createRegistrationId:&retrieveRegistrationError];
        if (retrieveRegistrationError) {
            if (error) {
                *error = retrieveRegistrationError;
            }
            return FALSE;
        }

        if (!registrationId) {
            if (error) {
                *error = [SBNotificationHubHelper errorWithMsg:@"Failed to create registration ID" code:-1016];
            }
            return FALSE;
        }

        if (storageManager) {
            [storageManager updateWithRegistrationName:name registrationId:registrationId eTag:@"*" deviceToken:deviceToken];
            NSError *operationError;
            result = [self upsertRegistrationWithName:name registrationId:registrationId payload:payload error:&operationError];
            if (operationError && error) {
                *error = operationError;
            }
        } else {
            if (error) {
                *error = [SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006];
            }
            return FALSE;
        }
    } else if (upsertRegistrationError && error) {
        *error = upsertRegistrationError;
    }

    return result;
}

- (NSString *)createRegistrationId:(NSError *__autoreleasing *)error {
    NSURL *requestUri = [self composeCreateRegistrationIdUri];
    if (!requestUri) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to compose request URI" code:-1012];
        }
        return nil;
    }

    NSHTTPURLResponse *response = nil;
    NSData *data;
    NSError *operationError;
    [self registrationOperationWithRequestUri:requestUri
                                      payload:@""
                                   httpMethod:@"POST"
                                         ETag:@""
                                     response:&response
                                 responseData:&data
                                        error:&operationError];

    if (operationError) {
        if (error) {
            *error = operationError;
        }
        return nil;
    }

    if (!response) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"No response received" code:-1013];
        }
        return nil;
    }

    NSString *locationField = [[response allHeaderFields] objectForKey:@"Location"];
    if (!locationField) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"No location field in response" code:-1014];
        }
        return nil;
    }

    NSURL *locationUrl = [[NSURL alloc] initWithString:locationField];
    if (!locationUrl) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Invalid location URL" code:-1015];
        }
        return nil;
    }

    NSString *registrationId = [self extractRegistrationIdFromLocationUri:locationUrl];
    if (!registrationId) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to extract registration ID" code:-1016];
        }
        return nil;
    }

    return registrationId;
}

- (BOOL)createRegistrationWithName:(NSString *)name payload:(NSString *)payload error:(NSError *__autoreleasing *)error {
    if (!name || !payload) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Invalid parameters for createRegistration" code:-1023];
        }
        return FALSE;
    }

    NSURL *requestUri = [self composeRegistrationUriWithRegistrationId:@""];
    if (!requestUri) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to compose request URI" code:-1012];
        }
        return FALSE;
    }

    NSHTTPURLResponse *response = nil;
    NSData *data;
    NSError *operationError;
    BOOL result = [self registrationOperationWithRequestUri:requestUri
                                                    payload:payload
                                                 httpMethod:@"POST"
                                                       ETag:@""
                                                   response:&response
                                               responseData:&data
                                                      error:&operationError];

    if (operationError == nil && data) {
        NSError *parseError;
        NSArray *registrations = [SBRegistrationParser parseRegistrations:data error:&parseError];
        if (!parseError && registrations.count > 0) {
            id registration = [registrations objectAtIndex:0];
            if ([registration isKindOfClass:[SBRegistration class]] && storageManager) {
                [storageManager updateWithRegistrationName:name registration:(SBRegistration *)registration];
            } else {
                parseError = [SBNotificationHubHelper errorWithMsg:@"Invalid registration object or storage manager nil" code:-1024];
            }
        } else {
            parseError = [SBNotificationHubHelper errorWithMsg:@"No registrations found or parse error" code:-1001];
        }
        if (parseError && error) {
            *error = parseError;
        }
    }

    if (operationError && error) {
        *error = operationError;
    }

    return result;
}

- (BOOL)upsertRegistrationWithName:(NSString *)name
                    registrationId:(NSString *)registrationId
                           payload:(NSString *)payload
                             error:(NSError *__autoreleasing *)error {
    if (!name || !registrationId || !payload) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Invalid parameters for upsertRegistration" code:-1017];
        }
        return FALSE;
    }

    NSURL *requestUri = [self composeRegistrationUriWithRegistrationId:registrationId];
    if (!requestUri) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to compose request URI" code:-1012];
        }
        return FALSE;
    }

    NSHTTPURLResponse *response = nil;
    NSData *data;
    NSError *operationError;
    BOOL result = [self registrationOperationWithRequestUri:requestUri
                                                    payload:payload
                                                 httpMethod:@"PUT"
                                                       ETag:@""
                                                   response:&response
                                               responseData:&data
                                                      error:&operationError];

    if (operationError == nil && data) {
        NSError *parseError;
        NSArray *registrations = [SBRegistrationParser parseRegistrations:data error:&parseError];
        if (!parseError && registrations.count > 0) {
            id registration = [registrations objectAtIndex:0];
            if ([registration isKindOfClass:[SBRegistration class]] && storageManager) {
                [storageManager updateWithRegistrationName:name registration:(SBRegistration *)registration];
            } else {
                parseError = [SBNotificationHubHelper errorWithMsg:@"Invalid registration object or storage manager nil" code:-1024];
            }
        } else {
            parseError = [SBNotificationHubHelper errorWithMsg:@"No registrations found or parse error" code:-1001];
        }
        if (parseError && error) {
            *error = parseError;
        }
    }

    if (operationError && error) {
        *error = operationError;
    }

    return result;
}

- (NSArray *)retrieveAllRegistrationsWithDeviceToken:(NSString *)deviceToken error:(NSError *__autoreleasing *)error {
    if (!deviceToken) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Device token is nil" code:-1019];
        }
        return nil;
    }

    NSURL *requestUri = [self composeRetrieveAllRegistrationsUriWithDeviceToken:deviceToken];
    if (!requestUri) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to compose request URI" code:-1012];
        }
        return nil;
    }

    NSHTTPURLResponse *response = nil;
    NSData *data;
    NSError *operationError;
    [self registrationOperationWithRequestUri:requestUri
                                      payload:@""
                                   httpMethod:@"GET"
                                         ETag:@""
                                     response:&response
                                 responseData:&data
                                        error:&operationError];

    if (operationError) {
        if ([operationError code] == 404) {
            return nil;
        }
        if (error) {
            *error = operationError;
        }
        return nil;
    }

    if (!data) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"No data in response" code:-1020];
        }
        return nil;
    }

    NSError *parseError;
    NSArray *registrations = [SBRegistrationParser parseRegistrations:data error:&parseError];
    if (parseError) {
        if (error) {
            *error = parseError;
        }
        return nil;
    }

    if (storageManager) {
        [storageManager deleteAllRegistrations];
        for (id retrieved in registrations) {
            if ([retrieved isKindOfClass:[SBRegistration class]]) {
                [storageManager updateWithRegistration:retrieved];
            }
        }
    } else {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006];
        }
        return nil;
    }

    return registrations;
}

- (BOOL)unregisterNativeWithError:(NSError *__autoreleasing *)error {
    NSString *name = [SBRegistration Name];
    if (!name) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to get registration name" code:-1003];
        }
        return FALSE;
    }
    return [self deleteRegistrationWithName:name error:error];
}

- (BOOL)unregisterTemplateWithName:(NSString *)name error:(NSError *__autoreleasing *)error {
    if (!name) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Template name is nil" code:-1007];
        }
        return FALSE;
    }

    if ([self verifyTemplateName:name error:error] == FALSE) {
        return FALSE;
    }

    return [self deleteRegistrationWithName:name error:error];
}

- (BOOL)deleteRegistrationWithName:(NSString *)name error:(NSError *__autoreleasing *)error {
    if (!name) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Template name is nil" code:-1007];
        }
        return FALSE;
    }

    StoredRegistrationEntry *cached = storageManager ? [storageManager getStoredRegistrationEntryWithRegistrationName:name] : nil;
    if (!cached) {
        return TRUE;
    }

    if (!cached.RegistrationId) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Cached registration ID is nil" code:-1010];
        }
        return FALSE;
    }

    NSURL *requestUri = [self composeRegistrationUriWithRegistrationId:cached.RegistrationId];
    if (!requestUri) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to compose request URI" code:-1012];
        }
        return FALSE;
    }

    NSHTTPURLResponse *response = nil;
    NSData *data;
    NSError *operationError;
    BOOL result = [self registrationOperationWithRequestUri:requestUri
                                                    payload:@""
                                                 httpMethod:@"DELETE"
                                                       ETag:@"*"
                                                   response:&response
                                               responseData:&data
                                                      error:&operationError];

    if (operationError == nil || [operationError code] == 404) {
        if (storageManager) {
            [storageManager deleteWithRegistrationName:name];
            operationError = nil;
        } else {
            operationError = [SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006];
        }
    }

    if (operationError && error) {
        *error = operationError;
    }

    return result;
}

- (BOOL)unregisterAllWithDeviceToken:(NSData *)deviceTokenData error:(NSError *__autoreleasing *)error {
    if (!deviceTokenData) {
        if (error) {
            *error = [SBNotificationHubHelper errorForNullDeviceToken];
        }
        return FALSE;
    }

    NSString *deviceToken = [self convertDeviceToken:deviceTokenData];
    if (!deviceToken) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to convert device token" code:-1002];
        }
        return FALSE;
    }

    NSError *operationError;
    NSArray *registrations = [self retrieveAllRegistrationsWithDeviceToken:deviceToken error:&operationError];
    if (operationError) {
        if (error) {
            *error = operationError;
        }
        return FALSE;
    }

    for (id reg in registrations) {
        if (![reg isKindOfClass:[SBRegistration class]]) {
            continue;
        }
        NSString *name = [SBNotificationHubHelper nameOfRegistration:reg];
        if (name) {
            [self deleteRegistrationWithName:name error:&operationError];
            if (operationError) {
                if (error) {
                    *error = operationError;
                }
                return FALSE;
            }
        }
    }

    if (storageManager) {
        [storageManager deleteAllRegistrations];
    } else {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Storage manager is nil" code:-1006];
        }
        return FALSE;
    }

    return TRUE;
}

- (BOOL)verifyTemplateName:(NSString *)name error:(NSError *__autoreleasing *)error {
    if (!name) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Template name is nil" code:-1007];
        }
        return FALSE;
    }

    if ([name isEqualToString:[SBRegistration Name]]) {
        if (error) {
            *error = [SBNotificationHubHelper errorForReservedTemplateName];
        }
        return FALSE;
    }

    NSRange range = [name rangeOfString:@":"];
    if (range.length > 0) {
        if (error) {
            *error = [SBNotificationHubHelper errorForInvalidTemplateName];
        }
        return FALSE;
    }

    return TRUE;
}

- (void)registrationOperationWithRequestUri:(NSURL *)requestUri
                                    payload:(NSString *)payload
                                 httpMethod:(NSString *)httpMethod
                                       ETag:(NSString *)etag
                                 completion:(void (^)(NSHTTPURLResponse *response, NSData *data, NSError *error))completion {
    if (!requestUri || !httpMethod) {
        if (completion) {
            completion(nil, nil, [SBNotificationHubHelper errorWithMsg:@"Invalid request parameters" code:-1025]);
        }
        return;
    }

    NSMutableURLRequest *theRequest = [self PrepareUrlRequest:requestUri httpMethod:httpMethod ETag:etag payload:payload];
    if (!theRequest) {
        if (completion) {
            completion(nil, nil, [SBNotificationHubHelper errorWithMsg:@"Failed to prepare URL request" code:-1026]);
        }
        return;
    }

    if (!tokenProvider) {
        if (completion) {
            completion(nil, nil, [SBNotificationHubHelper errorWithMsg:@"Token provider is nil" code:-1027]);
        }
        return;
    }

    [tokenProvider setTokenWithRequest:theRequest completion:^(NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, nil, error);
            }
            return;
        }

        SBURLConnection *connection = [[SBURLConnection alloc] init];
        if (!connection) {
            if (completion) {
                completion(nil, nil, [SBNotificationHubHelper errorWithMsg:@"Failed to create connection" code:-1028]);
            }
            return;
        }

        [connection sendRequest:theRequest completion:completion];
    }];
}

- (BOOL)registrationOperationWithRequestUri:(NSURL *)requestUri
                                    payload:(NSString *)payload
                                 httpMethod:(NSString *)httpMethod
                                       ETag:(NSString *)etag
                                   response:(NSHTTPURLResponse *__autoreleasing *)response
                               responseData:(NSData *__autoreleasing *)responseData
                                      error:(NSError *__autoreleasing *)error {
    if (!requestUri || !httpMethod) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Invalid request parameters" code:-1025];
        }
        return FALSE;
    }

    NSMutableURLRequest *theRequest = [self PrepareUrlRequest:requestUri httpMethod:httpMethod ETag:etag payload:payload];
    if (!theRequest) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to prepare URL request" code:-1026];
        }
        return FALSE;
    }

    if (!tokenProvider) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Token provider is nil" code:-1027];
        }
        return FALSE;
    }

    [tokenProvider setTokenWithRequest:theRequest error:error];
    if (*error) {
        return FALSE;
    }

    SBURLConnection *connection = [[SBURLConnection alloc] init];
    if (!connection) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"Failed to create connection" code:-1028];
        }
        return FALSE;
    }

    *responseData = [connection sendSynchronousRequest:theRequest returningResponse:response error:error];
    if (*error) {
        NSLog(@"Fail to perform registration operation: %@", [*error localizedDescription]);
        NSLog(@"Request: %@", [theRequest description]);
        NSLog(@"Headers: %@", [theRequest allHTTPHeaderFields]);
        if (*responseData) {
            NSLog(@"Error Response: %@", [[NSString alloc] initWithData:*responseData encoding:NSUTF8StringEncoding]);
        }
        return FALSE;
    }

    if (!*response) {
        if (error) {
            *error = [SBNotificationHubHelper errorWithMsg:@"No response received" code:-1013];
        }
        return FALSE;
    }

    NSInteger statusCode = [*response statusCode];
    if (statusCode != 200 && statusCode != 201) {
        NSString *responseString = *responseData ? [[NSString alloc] initWithData:*responseData encoding:NSUTF8StringEncoding] : @"";
        if (statusCode != 404) {
            NSLog(@"Fail to perform registration operation with status code: %ld", (long)statusCode);
            NSLog(@"Request: %@", [theRequest description]);
            NSLog(@"Headers: %@", [theRequest allHTTPHeaderFields]);
            NSLog(@"Error Response: %@", responseString);
        }

        if (error) {
            NSString *msg = [NSString stringWithFormat:@"Fail to perform registration operation. Response: %@", responseString];
            *error = [SBNotificationHubHelper errorWithMsg:msg code:statusCode];
        }
        return FALSE;
    }

    return TRUE;
}

- (NSURL *)composeRetrieveAllRegistrationsUriWithDeviceToken:(NSString *)deviceToken {
    if (!deviceToken || !_serviceEndPoint || !_path) {
        return nil;
    }

    NSString *fullPath = [NSString stringWithFormat:@"%@%@/Registrations/?$filter=deviceToken+eq+'%@'&api-version=%@",
                          [_serviceEndPoint absoluteString], _path, deviceToken, _APIVersion];
    return [[NSURL alloc] initWithString:fullPath];
}

- (NSURL *)composeRegistrationUriWithRegistrationId:(NSString *)registrationId {
    if (!_serviceEndPoint || !_path) {
        return nil;
    }

    NSString *safeRegistrationId = registrationId ?: @"";
    NSString *fullPath = [NSString stringWithFormat:@"%@%@/Registrations/%@?api-version=%@",
                          [_serviceEndPoint absoluteString], _path, safeRegistrationId, _APIVersion];
    return [[NSURL alloc] initWithString:fullPath];
}

- (NSURL *)composeCreateRegistrationIdUri {
    if (!_serviceEndPoint || !_path) {
        return nil;
    }

    NSString *fullPath = [NSString stringWithFormat:@"%@%@/registrationids/?api-version=%@",
                          [_serviceEndPoint absoluteString], _path, _APIVersion];
    return [[NSURL alloc] initWithString:fullPath];
}

- (NSMutableURLRequest *)PrepareUrlRequest:(NSURL *)uri
                                httpMethod:(NSString *)httpMethod
                                      ETag:(NSString *)etag
                                   payload:(NSString *)payload {
    if (!uri || !httpMethod) {
        return nil;
    }

    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:uri cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [theRequest setHTTPMethod:httpMethod];

    if (payload && [payload hasPrefix:@"{"]) {
        [theRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    } else {
        [theRequest setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    }

    if (etag && etag.length > 0) {
        NSString *formattedEtag = [etag isEqualToString:@"*"] ? etag : [NSString stringWithFormat:@"\"%@\"", etag];
        [theRequest addValue:formattedEtag forHTTPHeaderField:@"If-Match"];
    }

    if (payload && payload.length > 0) {
        [theRequest setHTTPBody:[payload dataUsingEncoding:NSUTF8StringEncoding]];
    }

    NSString *userAgent = [NSString stringWithFormat:_UserAgentTemplate,
                          _APIVersion,
                          [[UIDevice currentDevice] systemName] ?: @"iOS",
                          [[UIDevice currentDevice] systemVersion] ?: @"unknown"];
    [theRequest addValue:userAgent forHTTPHeaderField:@"User-Agent"];

    return theRequest;
}

- (NSString *)getRefreshDeviceTokenWithNewDeviceToken:(NSString *)newDeviceToken {
    if (!newDeviceToken) {
        return nil;
    }

    NSString *deviceToken = storageManager ? [storageManager deviceToken] : nil;
    return (deviceToken && deviceToken.length > 0) ? deviceToken : newDeviceToken;
}

- (NSString *)extractRegistrationIdFromLocationUri:(NSURL *)locationUrl {
    if (!locationUrl || !locationUrl.path) {
        return nil;
    }

    NSMutableCharacterSet *trimCharacterSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [trimCharacterSet addCharactersInString:@"/"];
    NSString *registrationIdPath = [locationUrl.path stringByTrimmingCharactersInSet:trimCharacterSet];
    if (!registrationIdPath) {
        return nil;
    }

    NSRange lastIndex = [registrationIdPath rangeOfString:@"/" options:NSBackwardsSearch];
    if (lastIndex.location == NSNotFound || lastIndex.location + 1 >= registrationIdPath.length) {
        return nil;
    }

    return [registrationIdPath substringFromIndex:lastIndex.location + 1];
}

@end
