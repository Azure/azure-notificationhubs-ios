// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSInstallationManager.h"
#import "MSInstallationTemplate.h"
#import "MSLocalStorage.h"
#import "MSTestFrameworks.h"
#import "WindowsAzureMessaging.h"
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface MSNotificationHubTemplateTests : XCTestCase
@property MSInstallationTemplate *template;
@end

@implementation MSNotificationHubTemplateTests

static NSString *connectionString = @"Endpoint=sb://test-namespace.servicebus.windows.net/"
                                    @";SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=HqKHjkhjg674hjGHdskJ795GJFJ=";
static NSString *hubName = @"nubName";
static NSString *key;

- (void)setUp {
    [super setUp];

    id notificationCenterMock = OCMClassMock([UNUserNotificationCenter class]);
    OCMStub(ClassMethod([notificationCenterMock currentNotificationCenter])).andReturn(nil);

    [MSNotificationHub initWithConnectionString:connectionString hubName:hubName];

    key = @"template1";
    NSString *tag1 = @"tag1";
    NSString *tag2 = @"tag2";
    NSString *body = @"body";
    NSString *headerObject = @"wns/title";
    NSString *headerKey = @"X-WNS-Type";
    _template = [MSInstallationTemplate new];
    [_template addTag:tag1];
    [_template addTag:tag2];
    [_template setBody:body];
    [_template setHeader:headerObject forKey:headerKey];
}

- (void)testAddTemplate {
    // If
    MSInstallation *installation = [MSInstallation new];
    [MSLocalStorage upsertInstallation:installation];

    // Then
    XCTAssertTrue([MSNotificationHub addTemplate:_template forKey:key]);
    MSInstallation *installationWithTemplate = [MSLocalStorage loadInstallation];
    XCTAssertNotNil(installationWithTemplate.templates);
    XCTAssertTrue([installationWithTemplate.templates count] == 1, @"Installation templates count actually is %lul",
                  [installationWithTemplate.templates count]);
    MSInstallationTemplate *actualTemplate = [installationWithTemplate.templates objectForKey:key];
    XCTAssertTrue([actualTemplate isEqual:_template]);
}

- (void)testAddTemplateDoesNotAddSameTemplate {
    // If
    MSInstallation *installation = [MSInstallation new];
    [installation addTemplate:_template forKey:key];
    [MSLocalStorage upsertInstallation:installation];

    // Then
    XCTAssertFalse([MSNotificationHub addTemplate:_template forKey:key]);
}

- (void)testRemoveTemplate {
    // If
    MSInstallation *installation = [MSInstallation new];
    [MSLocalStorage upsertInstallation:installation];
    [MSNotificationHub addTemplate:_template forKey:key];

    // Then
    XCTAssertTrue([MSNotificationHub removeTemplate:key]);
    MSInstallation *actualInstallation = [MSLocalStorage loadInstallation];
    XCTAssertTrue([actualInstallation.templates count] == 0, @"Installation templates count actually is %lul",
                  [actualInstallation.templates count]);
}

- (void)testRemoveTemplateReturnsNoForNotExistingTemplate {
    XCTAssertFalse([MSNotificationHub removeTemplate:@"not_existing_key"]);
}

- (void)testGetTemplate {
    // If
    MSInstallation *installation = [MSInstallation new];
    [installation addTemplate:_template forKey:key];
    [MSLocalStorage upsertInstallation:installation];

    // When
    MSInstallationTemplate *actualTemplate = [MSNotificationHub getTemplate:key];

    // Then
    XCTAssertNotNil(actualTemplate);
    XCTAssertTrue([actualTemplate isEqual:_template]);
}

@end
