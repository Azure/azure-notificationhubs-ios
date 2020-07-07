//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "AppDelegate.h"
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DevSettings" ofType:@"plist"];
    NSDictionary *configValues = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *connectionString = [configValues objectForKey:@"CONNECTION_STRING"];
    NSString *hubName = [configValues objectForKey:@"HUB_NAME"];
    
    [self addTags];
    
    [MSNotificationHub startWithConnectionString:connectionString hubName:hubName];
}

- (void) addTags {
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString *countryCode = [[NSLocale currentLocale] countryCode];
    
    // Create tags with type_value format
    NSString *languageTag = [NSString stringWithFormat:@"language_%@", language];
    NSString *countryCodeTag = [NSString stringWithFormat:@"country_%@", countryCode];

    [MSNotificationHub addTags:@[languageTag, countryCodeTag]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
