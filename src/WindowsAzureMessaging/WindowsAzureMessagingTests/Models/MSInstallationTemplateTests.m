// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>
#import "MSTestFrameworks.h"
#import "WindowsAzureMessaging.h"

@interface MSInstallationTemplateTests : XCTestCase

@end

@implementation MSInstallationTemplateTests

- (void)setUp {
    [super setUp];
}

- (void)testAddTag {
    // Arrange
    MSInstallationTemplate *template = [MSInstallationTemplate new];
    
    // Act
    XCTAssertTrue([template addTag:@"tag1"]);
    
    // Assert
    XCTAssertEqual(1, [[template tags] count]);
}

- (void)testAddTagDuplicateDoesNotAdd {
    MSInstallationTemplate *template = [MSInstallationTemplate new];
    NSString *tag = @"tag1";
    
    // Act
    XCTAssertTrue([template addTag:tag]);
    
    // Assert
    XCTAssertTrue([template addTag:@"tag1"]);
    XCTAssertEqual(1, [[template tags] count]);
}

- (void)testAddTagInvalidReturnsFalse {
    // Arrange
    MSInstallationTemplate *template = [MSInstallationTemplate new];
    NSString *tag = @"tag 1";
    
    // Act
    XCTAssertFalse([template addTag:tag]);
    
    // Assert
    XCTAssertEqual(0, [[template tags] count]);
}

- (void)testAddTags {
    // Arrange
    MSInstallationTemplate *template = [MSInstallationTemplate new];
    NSArray *tags = @[ @"tag1", @"tag2", @"tag3" ];
    
    // Act
    XCTAssertTrue([template addTags:tags]);
                   
    // Assert
    XCTAssertEqual(3, [[template tags] count]);
}

- (void)testAddTagsInvalidReturnsFalse {
    // Arrange
    MSInstallationTemplate *template = [MSInstallationTemplate new];
    NSArray *tags = @[@"tag 1", @"tag 2"];
    
    // Act
    XCTAssertFalse([template addTags:tags]);
    
    // Assert
    XCTAssertEqual(0, [[template tags] count]);
}

- (void)testRemoveTag {
    // Arrange
    MSInstallationTemplate *template = [MSInstallationTemplate new];
    NSArray *tags = @[@"tag1", @"tag2"];
    [template addTags:tags];
    
    // Act
    XCTAssertTrue([template removeTag:@"tag1"]);
    
    // Assert
    XCTAssertEqual(1, [[template tags] count]);
}

- (void)testRemoveTags {
    // Arrange
    MSInstallationTemplate *template = [MSInstallationTemplate new];
    NSArray *tags = @[@"tag1", @"tag2", @"tag3"];
    [template addTags:tags];
    NSArray *tagsToRemove = @[@"tag1", @"tag2"];
    
    // Act
    XCTAssertTrue([template removeTags:tagsToRemove]);
    
    // Assert
    XCTAssertEqual(1, [[template tags] count]);
}

- (void)testCleartags {
    // Arrange
    MSInstallationTemplate *template = [MSInstallationTemplate new];
    NSArray *tags = @[@"tag1", @"tag2", @"tag3"];
    [template addTags:tags];
    
    // Act
    [template clearTags];
    
    // Assert
    XCTAssertEqual(0, [[template tags] count]);
}

- (void)testSetHeader {
    // Arrange
    MSInstallationTemplate *template = [MSInstallationTemplate new];
    NSString *key = @"Sample-Key";
    NSString *value = @"Sample-Value";
    
    // Act
    [template setHeader:value forKey:value];
    
    // Assert
    XCTAssertEqual(value, [template getHeader:key]);
}

@end
