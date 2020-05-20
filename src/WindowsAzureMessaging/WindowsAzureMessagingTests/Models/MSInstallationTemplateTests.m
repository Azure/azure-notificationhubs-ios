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
    
    // Act
    XCTAssertTrue([template addTag:@"tag1"]);
    
    // Assert
    XCTAssertTrue([template addTag:@"tag1"]);
    XCTAssertEqual(1, [[template tags] count]);
}

- (void)testAddTagInvalidReturnsFalse {
    // Arrange
    MSInstallationTemplate *template = [MSInstallationTemplate new];
    NSString *tag = @"tag 1";
    
    // Act/Assert
    XCTAssertFalse([template addTag:tag]);
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

@end
