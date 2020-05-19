// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSInstallationManager.h"
#import "MSLocalStorage.h"
#import "MSTestFrameworks.h"
#import "WindowsAzureMessaging.h"
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface MSInstallationTests : XCTestCase

@end

@implementation MSInstallationTests

static NSString *connectionString = @"Endpoint=sb://test-namespace.servicebus.windows.net/"
                                    @";SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=HqKHjkhjg674hjGHdskJ795GJFJ=";
static NSString *hubName = @"nubName";

- (void)setUp {
    [super setUp];

    id notificationCenterMock = OCMClassMock([UNUserNotificationCenter class]);
    OCMStub(ClassMethod([notificationCenterMock currentNotificationCenter])).andReturn(nil);

    [MSNotificationHub initWithConnectionString:connectionString hubName:hubName];
}

- (void)testAddTag {
    // If
    MSInstallation *installation = [MSInstallation new];
    [MSLocalStorage upsertInstallation:installation];

    // Then
    XCTAssertTrue([MSNotificationHub addTag:@"tag1"]);
    MSInstallation *installationWithTag = [MSLocalStorage loadInstallation];
    XCTAssertTrue([installationWithTag.tags count] == 1, @"Installation tags count actually is %lul", [installationWithTag.tags count]);
    XCTAssertTrue([installationWithTag.tags containsObject:@"tag1"]);
}

- (void)testAddTagFailsIfTagDoesNotMatchPattern {
    // If
    MSInstallation *installation = [MSInstallation new];
    [MSLocalStorage upsertInstallation:installation];

    // Then
    XCTAssertFalse([MSNotificationHub addTag:@"tag 1"]);
    MSInstallation *installationWithTag = [MSLocalStorage loadInstallation];
    XCTAssertFalse([installationWithTag.tags containsObject:@"tag 1"]);
}

- (void)testAddTagFailsIfTagAlreadyExist {
    // If
    MSInstallation *installation = [MSInstallation new];
    installation.tags = [NSSet setWithArray:@[ @"tag1", @"tag2" ]];
    [MSLocalStorage upsertInstallation:installation];

    // Then
    XCTAssertTrue([MSNotificationHub addTag:@"tag1"]);
    MSInstallation *installationWithTag = [MSLocalStorage loadInstallation];
    XCTAssertTrue([installationWithTag.tags count] == 2, @"Installation tags count actually is %lul", [installationWithTag.tags count]);
}

- (void)testAddTags {
    // If
    MSInstallation *installation = [MSInstallation new];
    [MSLocalStorage upsertInstallation:installation];
    NSArray<NSString *> *tags = @[ @"tag1", @"tag2" ];

    // Then
    XCTAssertTrue([MSNotificationHub addTags:tags]);
    MSInstallation *installationWithTag = [MSLocalStorage loadInstallation];
    XCTAssertTrue([installationWithTag.tags count] == 2, @"Installation tags count actually is %lul", [installationWithTag.tags count]);
    XCTAssertTrue([installationWithTag.tags containsObject:@"tag1"]);
    XCTAssertTrue([installationWithTag.tags containsObject:@"tag2"]);
}

- (void)testRemoveTags {
    // If
    MSInstallation *installation = [MSInstallation new];
    installation.tags = [NSSet setWithArray:@[ @"tag1", @"tag2", @"tag3" ]];
    [MSLocalStorage upsertInstallation:installation];
    NSArray<NSString *> *tags = @[ @"tag1", @"tag2" ];

    // Then
    XCTAssertTrue([MSNotificationHub removeTags:tags]);
    MSInstallation *installationWithTag = [MSLocalStorage loadInstallation];
    XCTAssertTrue([installationWithTag.tags count] == 1, @"Installation tags count actually is %lul", [installationWithTag.tags count]);
    XCTAssertTrue([installationWithTag.tags containsObject:@"tag3"]);
}

- (void)testRemoveTagsFailsIfInstallationDoesNotHaveTags {
    // If
    MSInstallation *installation = [MSInstallation new];
    [MSLocalStorage upsertInstallation:installation];
    NSArray<NSString *> *tags = @[ @"tag1", @"tag2" ];

    // Then
    XCTAssertFalse([MSNotificationHub removeTags:tags]);
}

- (void)testClearTags {
    // If
    MSInstallation *installation = [MSInstallation new];
    installation.tags = [NSSet setWithArray:@[ @"tag1", @"tag2", @"tag3" ]];
    [MSLocalStorage upsertInstallation:installation];

    // Then
    XCTAssertNoThrow([MSNotificationHub clearTags]);
    MSInstallation *installationWithTag = [MSLocalStorage loadInstallation];
    XCTAssertTrue([installationWithTag.tags count] == 0, @"Installation tags count actually is %lul", [installationWithTag.tags count]);
}

- (void)testGetTags {
    // If
    MSInstallation *installation = [MSInstallation new];
    installation.tags = [NSSet setWithArray:@[ @"tag1", @"tag2", @"tag3" ]];
    [MSLocalStorage upsertInstallation:installation];

    // When
    NSArray<NSString *> *tags = [MSNotificationHub getTags];

    // Then
    XCTAssertNotNil(tags);
    XCTAssertTrue([tags count] == 3, @"Installation tags count actually is %lul", [tags count]);
}

@end
