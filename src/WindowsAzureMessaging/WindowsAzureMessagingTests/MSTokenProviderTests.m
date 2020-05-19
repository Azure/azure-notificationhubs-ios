// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSTestFrameworks.h"
#import "MSTokenProvider.h"
#import "WindowsAzureMessaging.h"

static NSMutableDictionary *connectionDictionary;

@interface MSTokenProviderTests : XCTestCase

@end

@implementation MSTokenProviderTests

- (void)setUp {
    [super setUp];
    connectionDictionary = [NSMutableDictionary new];
    [connectionDictionary setObject:@"sb://test.servicebus.windows.net" forKey:@"endpoint"];
    [connectionDictionary setObject:@"sharedaccesskeyname" forKey:@"sharedaccesskeyname"];
    [connectionDictionary setObject:@"sharedaccesskey" forKey:@"sharedaccesskey"];
    [connectionDictionary setObject:@"sharedsecretissuer" forKey:@"sharedsecretissuer"];
    [connectionDictionary setObject:@"sharedsecretvalue" forKey:@"sharedsecretvalue"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitWithConnectionDictionaryCorrect {
    MSTokenProvider *provider = [[MSTokenProvider alloc] initWithConnectionDictionary:connectionDictionary];
    XCTAssertNotNil(provider);
}

- (void)testCreateFromConnectionDictionary {
    MSTokenProvider *provider = [MSTokenProvider createFromConnectionDictionary:connectionDictionary];
    XCTAssertNotNil(provider);
}

- (void)testInitWithConnectionDictionaryIncorrect {
    [connectionDictionary setObject:@"test.servicebus.windows.net" forKey:@"endpoint"];
    MSTokenProvider *provider = [[MSTokenProvider alloc] initWithConnectionDictionary:connectionDictionary];
    XCTAssertNil(provider);
}

- (void)testGenerateSharedAccessTokenWithUrl {
    MSTokenProvider *provider = [MSTokenProvider createFromConnectionDictionary:connectionDictionary];
    NSString *token = [provider generateSharedAccessTokenWithUrl:@"https://test.url.com/hub"];

    XCTAssertNotNil(token);
    XCTAssertTrue([token containsString:@"SharedAccessSignature sr=http%3a%2f%2ftest.url.com%2fhub&sig="]);
}

@end
