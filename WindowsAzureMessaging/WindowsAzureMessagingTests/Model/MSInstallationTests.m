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
    [installation addTags:@[ @"tag1", @"tag2", @"tag3" ]];
    [installation setTemplate:templateA forKey:key];

    MSInstallation *installation2 = [MSInstallation new];
    installation2.installationId = installationId;
    [installation2 addTags:@[ @"tag1", @"tag2", @"tag3" ]];
    [installation2 setTemplate:templateB forKey:key];

    // Then
    XCTAssertTrue([installation isEqual:installation2]);
}

- (void)testToJson {
    // If
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
    NSString *pushChannel = @"740f4707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bb78ad";
    MSInstallation *installation1 = [MSInstallation new];
    installation1.installationId = installationId;
    installation1.pushChannel = pushChannel;
    [installation1 addTags:@[ @"tag1", @"tag2", @"tag3" ]];
    [installation1 setTemplate:templateA forKey:key];
    installation.userId = @"user";

    MSInstallation *installation2 = [MSInstallation new];
    installation2.installationId = installationId;
    installation2.pushChannel = pushChannel;
    [installation2 addTags:@[ @"tag1", @"tag2", @"tag3" ]];
    [installation2 setTemplate:templateB forKey:key];
    installation2.userId = @"user";
    
    // When
    NSData *installationData1 = [installation1 toJsonData];
    NSData *installationData2 = [installation2 toJsonData];
    
    // Then
    NSError *error1;
    NSError *error2;
    NSDictionary *jsonData1 = [NSJSONSerialization JSONObjectWithData:installationData1 options:0 error:&error1];
    NSDictionary *jsonData2 = [NSJSONSerialization JSONObjectWithData:installationData2 options:0 error:&error2];
    XCTAssertNil(error1);
    XCTAssertNil(error2);
    XCTAssertTrue([jsonData1 isEqualToDictionary:jsonData2]);
}

@end
