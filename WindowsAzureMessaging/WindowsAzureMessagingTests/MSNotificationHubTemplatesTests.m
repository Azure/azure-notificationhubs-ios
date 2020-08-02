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

    [MSNotificationHub startWithConnectionString:connectionString hubName:hubName];

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
    [_template setHeaderValue:headerObject forKey:headerKey];
}

- (void)testSetTemplate {
    // If
    MSInstallation *installation = [MSInstallation new];
    [MSLocalStorage upsertInstallation:installation];

    // Then
    XCTAssertTrue([MSNotificationHub setTemplate:_template forKey:key]);
    MSInstallation *installationWithTemplate = [MSLocalStorage loadInstallation];
    XCTAssertNotNil(installationWithTemplate.templates);
    XCTAssertTrue([installationWithTemplate.templates count] == 1, @"Installation templates count actually is %lul",
                  [installationWithTemplate.templates count]);
    MSInstallationTemplate *actualTemplate = [installationWithTemplate.templates objectForKey:key];
    XCTAssertTrue([actualTemplate isEqual:_template]);
}

- (void)testRemoveTemplate {
    // If
    MSInstallation *installation = [MSInstallation new];
    [MSLocalStorage upsertInstallation:installation];
    [MSNotificationHub setTemplate:_template forKey:key];

    // Then
    XCTAssertTrue([MSNotificationHub removeTemplateForKey:key]);
    MSInstallation *actualInstallation = [MSLocalStorage loadInstallation];
    XCTAssertTrue([actualInstallation.templates count] == 0, @"Installation templates count actually is %lul",
                  [actualInstallation.templates count]);
}

- (void)testRemoveTemplateReturnsNoForNotExistingTemplate {
    XCTAssertFalse([MSNotificationHub removeTemplateForKey:@"not_existing_key"]);
}

- (void)testGetTemplate {
    // If
    MSInstallation *installation = [MSInstallation new];
    [installation setTemplate:_template forKey:key];
    [MSLocalStorage upsertInstallation:installation];

    // When
    MSInstallationTemplate *actualTemplate = [MSNotificationHub getTemplateForKey:key];

    // Then
    XCTAssertNotNil(actualTemplate);
    XCTAssertTrue([actualTemplate isEqual:_template]);
}

@end
