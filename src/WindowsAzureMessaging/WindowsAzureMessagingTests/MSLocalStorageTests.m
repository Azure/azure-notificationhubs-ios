// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "WindowsAzureMessaging.h"
#import "MSTestFrameworks.h"
#import "MSLocalStorage.h"
#import "MSInstallation.h"

static MSInstallation *installation;

@interface MSLocalStorageTests : XCTestCase

@end

@implementation MSLocalStorageTests

- (void)setUp {
    [super setUp];
    
    installation = [MSInstallation new];
}

- (void)tearDown {
    [super tearDown];
}

-(void) testUpsertInstallation {
    MSInstallation *inst = [MSLocalStorage upsertInstallation:installation];
    XCTAssertNotNil(inst);
}

-(void) testUpsertAndLoadInstallation {
    [MSLocalStorage upsertInstallation:installation];
    MSInstallation *inst = [MSLocalStorage loadInstallation];
    XCTAssertEqualObjects(installation.installationID, inst.installationID);
    XCTAssertEqualObjects(installation.platform, inst.platform);
    XCTAssertEqualObjects(installation.pushChannel, inst.pushChannel);
}

@end
