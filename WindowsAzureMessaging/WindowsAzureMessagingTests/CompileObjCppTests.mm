// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <XCTest/XCTest.h>

@interface CompileObjCppTests : XCTestCase

@end

#import "WindowsAzureMessaging.h"

@implementation CompileObjCppTests

- (void)testCppCompilation {
    // This test exists to verify that Objective C++ compilation succeeds.
    // C++ introduces some new keywords (such as `template`), so we avoid using those keywords in public signatures.
    MSInstallation *installation = [MSInstallation new];
    XCTAssertNotNil(installation);
}

@end
