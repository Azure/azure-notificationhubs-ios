// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSInstallation.h"
#import "MSTestFrameworks.h"
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface MSInstallationTests : XCTestCase

@end

@implementation MSInstallationTests


- (void)setUp {
    [super setUp];
}

- (void)testAddTag {
    // If
    MSInstallation *installation = [[MSInstallation alloc] init];

    // Then
    XCTAssertTrue([installation addTag:@"tag1"]);
    XCTAssertTrue([installation.tags count] == 1, @"Installation tags count actually is %lul", [installation.tags count]);
    XCTAssertTrue([installation.tags containsObject:@"tag1"]);
}

- (void)testAddTagFailsIfTagDoesNotMatchPattern {
    // If
    MSInstallation *installation = [[MSInstallation alloc] init];

    // Then
    XCTAssertFalse([installation addTag:@"tag 1"]);
    XCTAssertFalse([installation.tags containsObject:@"tag 1"]);
}

- (void)testAddTagFailsIfTagAlreadyExist {
    // If
    MSInstallation *installation = [[MSInstallation alloc] init];
    [installation addTags:@[@"tag1", @"tag2" ]];

    // Then
    XCTAssertTrue([installation addTag:@"tag1"]);
    XCTAssertTrue([installation.tags count] == 2, @"Installation tags count actually is %lul", [installation.tags count]);
}

- (void)testAddTags {
    // If
    MSInstallation *installation = [MSInstallation new];
    NSArray<NSString *> *tags = @[ @"tag1", @"tag2" ];

    // Then
    XCTAssertTrue([installation addTags:tags]);
    XCTAssertTrue([installation.tags count] == 2, @"Installation tags count actually is %lul", [installation.tags count]);
    XCTAssertTrue([installation.tags containsObject:@"tag1"]);
    XCTAssertTrue([installation.tags containsObject:@"tag2"]);
}

- (void)testRemoveTags {
    // If
    MSInstallation *installation = [MSInstallation new];
    [installation addTags:@[ @"tag1", @"tag2", @"tag3" ]];
    NSArray<NSString *> *tags = @[ @"tag1", @"tag2" ];

    // Then
    XCTAssertTrue([installation removeTags:tags]);
    XCTAssertTrue([installation.tags count] == 1, @"Installation tags count actually is %lul", [installation.tags count]);
    XCTAssertTrue([installation.tags containsObject:@"tag3"]);
}

- (void)testClearTags {
    // If
    MSInstallation *installation = [MSInstallation new];
    [installation addTags:@[ @"tag1", @"tag2", @"tag3" ]];

    // Then
    XCTAssertNoThrow([installation clearTags]);
    XCTAssertTrue([installation.tags count] == 0, @"Installation tags count actually is %lul", [installation.tags count]);
}

- (void)testGetTags {
    // If
    MSInstallation *installation = [MSInstallation new];
    [installation addTags:@[ @"tag1", @"tag2", @"tag3" ]];

    // When
    NSArray<NSString *> *tags = [installation getTags];

    // Then
    XCTAssertNotNil(tags);
    XCTAssertTrue([tags count] == 3, @"Installation tags count actually is %lul", [tags count]);
}

@end
