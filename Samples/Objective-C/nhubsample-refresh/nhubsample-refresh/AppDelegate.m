//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"devsettings" ofType:@"plist"];
    NSDictionary *configValues = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *connectionString = [configValues objectForKey:@"connectionString"];
    NSString *hubName = [configValues objectForKey:@"hubName"];
    
    [MSNotificationHub setEnrichmentDelegate: self];
    [MSNotificationHub setManagementDelegate: self];
    [MSNotificationHub setLifecycleDelegate: self];
    [MSNotificationHub initWithConnectionString:connectionString hubName:hubName];
    [MSNotificationHub addTag:@"userAgent:com.example.nhubsample-refresh:1.0"];
    
    return YES;
}

- (void)notificationHub:(MSNotificationHub *)notificationHub willEnrichInstallation:(MSInstallation *)installation{
    NSLog(@"willEnrichInstallation");
}

// Sample usage of MSInstallationManagementDelegate
//- (void)notificationHub:(MSNotificationHub *)notificationHub willUpsertInstallation:(MSInstallation *)installation
//  completionHandler:(void(^)(NSError * _Nullable))completionHandler {
//    NSLog(@"Will do upsert on custom back end.");
//    completionHandler([NSError errorWithDomain:@"WindowsAzureMessaging" code:-1 userInfo:@{@"Error": @"not implemented"}]);
//}

//- (void)notificationHub:(MSNotificationHub *)notificationHub willDeleteInstallation:(NSString *)installationId {
//    NSLog(@"Will do delete on custom back end.");
//}

- (void)notificationHub:(MSNotificationHub *)notificationHub didSaveInstallation:(MSInstallation *)installation {
    NSLog(@"didSaveInstallation");
}

- (void)notificationHub:(MSNotificationHub *)notificationHub didFailToSaveInstallationWithError:(NSError *)error {
    NSLog(@"didFailToSaveInstallationWithError: %@", error.userInfo);
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
