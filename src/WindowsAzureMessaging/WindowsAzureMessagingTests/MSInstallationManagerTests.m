// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "WindowsAzureMessaging.h"
#import "MSTestFrameworks.h"
#import "MSHttpClientPrivate.h"
#import "MSInstallationManager.h"
#import "MSLocalStorage.h"

@interface MSInstallationManagerTests : XCTestCase

@end

static NSString *connectionString = @"Endpoint=sb://test-namespace.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=HqKHjkhjg674hjGHdskJ795GJFJ=";
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

-(void) testSaveInstallation {
    // If
    MSHttpClient *httpClient = OCMPartialMock([MSHttpClient new]);
    NSString *method = @"PUT";
    OCMStub([httpClient sendCallAsync:OCMOCK_ANY]).andDo(nil);
    
    MSInstallationManager *installationManager = [[MSInstallationManager alloc] initWithConnectionString:connectionString hubName:hubName];
    MSInstallation *installation = [MSLocalStorage loadInstallation];
    [installation setPushChannel:deviceToken];
    [installationManager setHttpClient:httpClient];
    
    NSString *expectedUrl = [NSString stringWithFormat:@"https://test-namespace.servicebus.windows.net/nubName/installations/%@?api-version=2017-04", installation.installationID];
    NSString *expectedSasTokenUrl = [NSString stringWithFormat:@"http://test-namespace.servicebus.windows.net/nubName/installations/%@", installation.installationID];
    NSString *encodedSasTokenUrl = [expectedSasTokenUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *expectedSubstring = [NSString stringWithFormat:@"SharedAccessSignature sr=%@", encodedSasTokenUrl];
    
    NSDictionary * dictionary = @{
           @"installationId" : installation.installationID,
           @"platform" : installation.platform,
           @"pushChannel" : installation.pushChannel,
           @"tags" : installation.tags ?: @""
    };

    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:NSJSONWritingPrettyPrinted error:nil];
    // When
    [installationManager saveInstallation:installation];
    
    // Then
    OCMVerify([httpClient sendAsync:[OCMArg checkWithBlock:^BOOL(NSURL *url){
        XCTAssertTrue([expectedUrl isEqualToString:[url absoluteString]]);
        return YES;
    }]
        method:method
        headers:[OCMArg checkWithBlock:^BOOL(NSDictionary<NSString *, NSString *> *headers){
            NSString *sasToken = [headers objectForKey:@"Authorization"];
            XCTAssertTrue([headers count] == 3);
            XCTAssertNotNil(sasToken);
            XCTAssertFalse([sasToken rangeOfString:expectedSubstring options:NSCaseInsensitiveSearch].location == NSNotFound);
        
            return YES;
        }]
        data:[OCMArg checkWithBlock:^BOOL(NSData *data){
            XCTAssertTrue([expectedData isEqualToData:data]);
            return YES;
        }]
        completionHandler:OCMOCK_ANY]);
}

-(void) testSaveInstallationFailsIfNoPushChannel {
    // If
    MSHttpClient *httpClient = OCMPartialMock([MSHttpClient new]);
    MSInstallationManager *installationManager = [[MSInstallationManager alloc] initWithConnectionString:connectionString hubName:hubName];
    [installationManager setHttpClient:httpClient];
    MSInstallation *installation = [MSLocalStorage loadInstallation];
    
    // Then
    OCMReject([httpClient sendAsync:OCMOCK_ANY method:OCMOCK_ANY headers:OCMOCK_ANY data:OCMOCK_ANY completionHandler:OCMOCK_ANY]);
        
    // When
    [installationManager saveInstallation:installation];
}

-(void) testSaveInstallationFailsIfInvalidConnectionString {
    // If
    MSHttpClient *httpClient = OCMPartialMock([MSHttpClient new]);
    MSInstallationManager *installationManager = [[MSInstallationManager alloc] initWithConnectionString:@"" hubName:hubName];
    MSInstallation *installation = [MSLocalStorage loadInstallation];
    [installation setPushChannel:deviceToken];
    [installationManager setHttpClient:httpClient];
    
    // Then
    OCMReject([httpClient sendAsync:OCMOCK_ANY method:OCMOCK_ANY headers:OCMOCK_ANY data:OCMOCK_ANY completionHandler:OCMOCK_ANY]);
        
    // When
    [installationManager saveInstallation:installation];
}

@end
