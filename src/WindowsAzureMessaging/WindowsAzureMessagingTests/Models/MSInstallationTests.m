// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSInstallation.h"
#import "MSInstallationTemplate.h"
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
    [installation addTags:@[ @"tag1", @"tag2" ]];

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

- (void)testInstallationsEquality {
    // If
    NSString *dateString = @"01-01-2030";
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    MSInstallationTemplate *templateA = [MSInstallationTemplate new];
    [templateA setBody:@"body"];
    [templateA addTags:@[ @"tag1", @"tag2" ]];
    [templateA setHeaderValue:@"Sample-Value" forKey:@"Sample-Key"];

    MSInstallationTemplate *templateB = [MSInstallationTemplate new];
    [templateB setBody:@"body"];
    [templateB addTags:@[ @"tag1", @"tag2" ]];
    [templateB setHeaderValue:@"Sample-Value" forKey:@"Sample-Key"];

    NSString *installationId = @"installationID";
    NSString *key = @"key";
    MSInstallation *installation = [MSInstallation new];
    installation.installationId = installationId;
    installation.expiration = [dateFormatter dateFromString:dateString];
    [installation addTags:@[ @"tag1", @"tag2", @"tag3" ]];
    [installation setTemplate:templateA forKey:key];

    MSInstallation *installation2 = [MSInstallation new];
    installation2.installationId = installationId;
    installation2.expiration = [dateFormatter dateFromString:dateString];
    [installation2 addTags:@[ @"tag1", @"tag2", @"tag3" ]];
    [installation2 setTemplate:templateB forKey:key];

    // Then
    XCTAssertTrue([installation isEqual:installation2]);
}

@end
