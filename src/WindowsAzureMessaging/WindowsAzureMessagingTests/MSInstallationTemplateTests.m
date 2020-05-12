//  MSInstallationTemplateTests.m
//  WindowsAzureMessagingTests

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "WindowsAzureMessaging.h"
#import "MSTestFrameworks.h"
#import "MSInstallationManager.h"
#import "MSInstallationTemplate.h"
#import "MSLocalStorage.h"

@interface MSInstallationTemplateTests : XCTestCase
@property MSInstallationTemplate *template;
@end

@implementation MSInstallationTemplateTests

static NSString *key;

- (void)setUp {
    [super setUp];
    
    id notificationCenterMock = OCMClassMock([UNUserNotificationCenter class]);
    OCMStub(ClassMethod([notificationCenterMock currentNotificationCenter])).andReturn(nil);
    
    key = @"template1";
    NSString *tag1 = @"tag1";
    NSString *tag2 = @"tag2";
    NSString *body = @"body";
    NSString *headerObject = @"wns/title";
    NSString *headerKey = @"X-WNS-Type";
    _template = [MSInstallationTemplate new];
    [_template.tags addObject:tag1];
    [_template.tags addObject:tag2];
    [_template setBody:body];
    [_template.headers setObject:headerObject forKey:headerKey];
}


-(void) testAddTemplate{
    // If
    MSInstallation *installation = [MSInstallation new];
    [MSLocalStorage upsertInstallation:installation];
        
    // Then
    XCTAssertTrue([MSNotificationHub addTemplate:_template forKey:key]);
    MSInstallation *installationWithTemplate = [MSLocalStorage loadInstallation];
    XCTAssertNotNil(installationWithTemplate.templates);
    XCTAssertTrue([installationWithTemplate.templates count] == 1, @"Installation templates count actually is %lul", [installationWithTemplate.templates count]);
    MSInstallationTemplate *actualTemplate = [installationWithTemplate.templates objectForKey:key];
    XCTAssertTrue([actualTemplate isEqual:_template]);
}

-(void) testAddTemplateDoesNotAddSameTemplate{
    // If
    MSInstallation *installation = [MSInstallation new];
    [installation addTemplate:_template forKey:key];
    [MSLocalStorage upsertInstallation:installation];
    
    // Then
    XCTAssertFalse([MSNotificationHub addTemplate:_template forKey:key]);
}
    
-(void) testRemoveTemplate{
    // If
    MSInstallation *installation = [MSInstallation new];
    [MSLocalStorage upsertInstallation:installation];
    [MSNotificationHub addTemplate:_template forKey:key];

    // Then
    XCTAssertTrue([MSNotificationHub removeTemplate:key]);
    MSInstallation *actualInstallation = [MSLocalStorage loadInstallation];
    XCTAssertTrue([actualInstallation.templates count] == 0, @"Installation templates count actually is %lul", [actualInstallation.templates count]);
}
    
-(void) testRemoveTemplateReturnsNoForNotExistingTemplate{
    XCTAssertFalse([MSNotificationHub removeTemplate:@"not_existing_key"]);
}

-(void) testGetTemplate{
    // If
    MSInstallation *installation = [MSInstallation new];
    [MSLocalStorage upsertInstallation:installation];
    [MSNotificationHub addTemplate:_template forKey:key];

    // When
    MSInstallationTemplate *actualTemplate = [MSNotificationHub getTemplate:key];
    
    // Then
    XCTAssertNotNil(actualTemplate);
    XCTAssertTrue([actualTemplate isEqual:_template]);    
}

@end
