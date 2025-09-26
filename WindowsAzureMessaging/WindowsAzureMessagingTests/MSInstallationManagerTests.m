// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "ANHHttpClient+Private.h"
#import "MSInstallationManager+Private.h"
#import "MSInstallationManager.h"
#import "MSInstallation.h"
#import "MSInstallation+Private.h"
#import "MSInstallationTemplate.h"
#import "MSLocalStorage.h"
#import "MSTestFrameworks.h"
#import "WindowsAzureMessaging.h"

@interface MSInstallationManagerTests : XCTestCase

@end

static NSString *connectionString = @"Endpoint=sb://test-namespace.servicebus.windows.net/"
                                    @";SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=MOCK1234567890abcdefghijklmnopqrstuvwxyzABCDEF=";
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
    ANHHttpClient *httpClient = OCMPartialMock([ANHHttpClient new]);
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

    // Set expiration time
    NSTimeInterval expirationInSeconds = 60L * 60L * 24L * 90L;
    installation.expirationTime = [[NSDate date] dateByAddingTimeInterval:expirationInSeconds];

    // When
    [installationManager saveInstallation:installation
        withEnrichmentHandler:^(void) {
        }
        withManagementHandler:^BOOL(__unused InstallationCompletionHandler completion) {
          return false;
        }
        completionHandler:^void(__unused NSError *_Nullable error) {
        }];

    // Then
    OCMVerify(
        [httpClient
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
            
                NSError *jsonError = nil;
                NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                MSInstallation *resultInstallation = [MSInstallation createFromJSON:resultJSON];
                XCTAssertTrue([resultInstallation.installationId isEqual:installation.installationId]);
                XCTAssertTrue([resultInstallation.pushChannel isEqual:installation.pushChannel]);
        
                XCTAssertTrue([[NSCalendar currentCalendar] isDate:resultInstallation.expirationTime equalToDate:installation.expirationTime toUnitGranularity:NSCalendarUnitDay]);
                return YES;
            }]
            completionHandler:OCMOCK_ANY]
    );
}

- (void)testSaveInstallationWithoutExpiration {
    // If
    ANHHttpClient *httpClient = OCMPartialMock([ANHHttpClient new]);
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

    // Set expiration time
    NSTimeInterval expirationInSeconds = 60L * 60L * 24L * 90L;
    NSDate *currentDate = [[NSDate date] dateByAddingTimeInterval:expirationInSeconds];

    // When
    [installationManager saveInstallation:installation
        withEnrichmentHandler:^(void) {
        }
        withManagementHandler:^BOOL(__unused InstallationCompletionHandler completion) {
          return false;
        }
        completionHandler:^void(__unused NSError *_Nullable error) {
        }];

    // Then
    OCMVerify(
        [httpClient
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
            
                NSError *jsonError = nil;
                NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                MSInstallation *resultInstallation = [MSInstallation createFromJSON:resultJSON];
                XCTAssertTrue([resultInstallation.installationId isEqual:installation.installationId]);
                XCTAssertTrue([resultInstallation.pushChannel isEqual:installation.pushChannel]);
        
                XCTAssertTrue([[NSCalendar currentCalendar] isDate:resultInstallation.expirationTime equalToDate:currentDate toUnitGranularity:NSCalendarUnitDay]);
                return YES;
            }]
            completionHandler:OCMOCK_ANY]
    );
}

- (void)testSaveInstallationFailsIfNoPushChannel {
    // If
    ANHHttpClient *httpClient = OCMPartialMock([ANHHttpClient new]);
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
    ANHHttpClient *httpClient = OCMPartialMock([ANHHttpClient new]);
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
