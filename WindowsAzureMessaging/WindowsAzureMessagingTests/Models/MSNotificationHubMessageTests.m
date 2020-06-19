// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSNotificationHubMessage.h"
#import "MSTestFrameworks.h"
#import "WindowsAzureMessaging.h"
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface MSNotificationHubMessageTests : XCTestCase

@end

@implementation MSNotificationHubMessageTests

- (void)testInitWithUserInfo {
    NSDictionary *userInfo = @{
        @"data" : @{
            @"key" : @"value",
        },
    };

    MSNotificationHubMessage *message = [[MSNotificationHubMessage alloc] initWithUserInfo:userInfo];

    XCTAssertNotNil(message.userInfo);
    XCTAssertEqual(@"value", [[message.userInfo valueForKey:@"data"] valueForKey:@"key"]);
}

- (void)testInitWithAlertTitle {
    NSDictionary *userInfo = @{
        @"aps" : @{
            @"alert" : @{
                @"title" : @"The title",
            },
        },
    };

    MSNotificationHubMessage *message = [[MSNotificationHubMessage alloc] initWithUserInfo:userInfo];

    XCTAssertEqual(@"The title", message.title);
    XCTAssertEqual(@"The title", [[[message.userInfo valueForKey:@"aps"] valueForKey:@"alert"] valueForKey:@"title"]);
}

- (void)testInitWithAlertBody {
    NSDictionary *userInfo = @{
        @"aps" : @{
            @"alert" : @{
                @"title" : @"The title",
                @"body" : @"The body",
            },
        },
    };

    MSNotificationHubMessage *message = [[MSNotificationHubMessage alloc] initWithUserInfo:userInfo];

    XCTAssertEqual(@"The body", message.body);
    XCTAssertEqual(@"The body", [[[message.userInfo valueForKey:@"aps"] valueForKey:@"alert"] valueForKey:@"body"]);
}

- (void)testInitWithAlertText {
    NSDictionary *userInfo = @{
        @"aps" : @{
            @"alert" : @"The body",
        },
    };

    MSNotificationHubMessage *message = [[MSNotificationHubMessage alloc] initWithUserInfo:userInfo];

    XCTAssertNil(message.title);
    XCTAssertEqual(@"The body", message.body);
    XCTAssertEqual(@"The body", [[message.userInfo valueForKey:@"aps"] valueForKey:@"alert"]);
}

- (void)testInitWithUnknownAlert {
    NSDictionary *userInfo = @{
        @"aps" : @{
            @"alert" : @123,
        },
    };

    MSNotificationHubMessage *message = [[MSNotificationHubMessage alloc] initWithUserInfo:userInfo];

    XCTAssertNil(message.title);
    XCTAssertNil(message.body);
    XCTAssertEqual(@123, [[message.userInfo valueForKey:@"aps"] valueForKey:@"alert"]);
}

@end
