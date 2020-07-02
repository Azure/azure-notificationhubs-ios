// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSHttpClient+Private.h"
#import "MSInstallationManager.h"
#import "MSInstallationManager+Private.h"
#import "MSInstallationTemplate.h"
#import "MSLocalStorage.h"
#import "MSTestFrameworks.h"
#import "WindowsAzureMessaging.h"

@interface MSInstallationManagerTests : XCTestCase

@end

static NSString *connectionString = @"Endpoint=sb://test-namespace.servicebus.windows.net/"
                                    @";SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=HqKHjkhjg674hjGHdskJ795GJFJ=";
static NSString *hubName = @"nubName";
static NSString *deviceToken = @"deviceToken";

@implementation MSInstallationManagerTests

- (void)setUp {
    [super setUp];
    [MSLocalStorage upsertInstallation:[MSInstallation new]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSaveInstallation {
    // If
    MSHttpClient *httpClient = OCMPartialMock([MSHttpClient new]);
    NSString *method = @"PUT";
    OCMStub([httpClient sendCallAsync:OCMOCK_ANY]).andDo(nil);

    MSInstallationManager *installationManager = [[MSInstallationManager alloc] initWithConnectionString:connectionString hubName:hubName];
    MSInstallation *installation = [MSLocalStorage loadInstallation];
    [installation setPushChannel:deviceToken];
    [installationManager setHttpClient:httpClient];

    NSString *expectedUrl =
        [NSString stringWithFormat:@"https://test-namespace.servicebus.windows.net/nubName/installations/%@?api-version=2020-06",
                                   installation.installationId];
    NSString *expectedSasTokenUrl =
        [NSString stringWithFormat:@"http://test-namespace.servicebus.windows.net/nubName/installations/%@", installation.installationId];
    NSString *encodedSasTokenUrl =
        [expectedSasTokenUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *expectedSubstring = [NSString stringWithFormat:@"SharedAccessSignature sr=%@", encodedSasTokenUrl];

    NSMutableDictionary *templates = [NSMutableDictionary new];
    for (NSString *key in [installation.templates allKeys]) {
        [templates setObject:[[installation.templates objectForKey:key] toDictionary] forKey:key];
    };

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"installationId" : installation.installationId,
        @"platform" : @"apns",
        @"pushChannel" : installation.pushChannel
    }];

    if (installation.tags && [installation.tags count] > 0) {
        [dictionary setObject:[NSArray arrayWithArray:[installation.tags allObjects]] forKey:@"tags"];
    }

    if (installation.templates && [installation.templates count] > 0) {
        [dictionary setObject:templates forKey:@"templates"];
    }

    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];

    // When
    [installationManager saveInstallation:installation
        withEnrichmentHandler:^(void) {
        }
        withManagementHandler:^BOOL(__unused InstallationCompletionHandler completion) {
          return false;
        }
        completionHandler:^void(__unused NSError *_Nullable error){
        }];

    // Then
    OCMVerify([httpClient
                sendAsync:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
                  XCTAssertTrue([expectedUrl isEqualToString:[url absoluteString]]);
                  return YES;
                }]
                   method:method
                  headers:[OCMArg checkWithBlock:^BOOL(NSDictionary<NSString *, NSString *> *headers) {
                    NSString *sasToken = [headers objectForKey:@"Authorization"];
                    XCTAssertTrue([headers count] == 4);
                    XCTAssertNotNil(sasToken);
                    XCTAssertFalse([sasToken rangeOfString:expectedSubstring options:NSCaseInsensitiveSearch].location == NSNotFound);

                    return YES;
                  }]
                     data:[OCMArg checkWithBlock:^BOOL(NSData *data) {
                       XCTAssertTrue([expectedData isEqualToData:data]);
                       return YES;
                     }]
        completionHandler:OCMOCK_ANY]);
}

- (void)testSaveInstallationFailsIfNoPushChannel {
    // If
    MSHttpClient *httpClient = OCMPartialMock([MSHttpClient new]);
    MSInstallationManager *installationManager = [[MSInstallationManager alloc] initWithConnectionString:connectionString hubName:hubName];
    [installationManager setHttpClient:httpClient];
    MSInstallation *installation = [MSLocalStorage loadInstallation];

    // Then
    OCMReject([httpClient sendAsync:OCMOCK_ANY method:OCMOCK_ANY headers:OCMOCK_ANY data:OCMOCK_ANY completionHandler:OCMOCK_ANY]);

    // When
    [installationManager saveInstallation:installation
        withEnrichmentHandler:^(void) {
        }
        withManagementHandler:^BOOL(__unused InstallationCompletionHandler completion) {
          return false;
        }
        completionHandler:^void(__unused NSError *_Nullable error){
        }];
}

- (void)testSaveInstallationFailsIfInvalidConnectionString {
    // If
    MSHttpClient *httpClient = OCMPartialMock([MSHttpClient new]);
    MSInstallationManager *installationManager = [[MSInstallationManager alloc] initWithConnectionString:@"" hubName:hubName];
    MSInstallation *installation = [MSLocalStorage loadInstallation];
    [installation setPushChannel:deviceToken];
    [installationManager setHttpClient:httpClient];

    // Then
    OCMReject([httpClient sendAsync:OCMOCK_ANY method:OCMOCK_ANY headers:OCMOCK_ANY data:OCMOCK_ANY completionHandler:OCMOCK_ANY]);

    // When
    [installationManager saveInstallation:installation
        withEnrichmentHandler:^(void) {
        }
        withManagementHandler:^BOOL(__unused InstallationCompletionHandler completion) {
          return false;
        }
        completionHandler:^void(__unused NSError *_Nullable error){
        }];
}

@end
