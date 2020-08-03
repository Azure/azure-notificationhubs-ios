//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DevSettings" ofType:@"plist"];
    NSDictionary *configValues = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *connectionString = [configValues objectForKey:@"CONNECTION_STRING"];
    NSString *hubName = [configValues objectForKey:@"HUB_NAME"];
    
    if([connectionString length] != 0 && [hubName length] != 0) {
        [MSNotificationHub startWithConnectionString:connectionString hubName:hubName];
        
        [self addTags];
        
        return YES;
    }
    
    NSLog(@"Please setup CONNECTION_STRING and HUB_NAME in DevSettings.plist and restart application");
    
    exit(-1);
}

// Adds some basic tags such as language and country
- (void)addTags {
    // Get language and country code for common tag values
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString *countryCode = [[NSLocale currentLocale] countryCode];

    // Create tags with type_value format
    NSString *languageTag = [NSString stringWithFormat:@"language_%@", language];
    NSString *countryCodeTag = [NSString stringWithFormat:@"country_%@", countryCode];

    [MSNotificationHub addTags:@[languageTag, countryCodeTag]];
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
