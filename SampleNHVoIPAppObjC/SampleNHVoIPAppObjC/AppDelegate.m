//
//  AppDelegate.m
//  SampleNHVoIPAppObjC
//
//  Created by Matthew Podwysocki on 10/16/21.
//

#import "AppDelegate.h"
#import "AppConstants.h"
#import <PushKit/PushKit.h>
#import <CallKit/CallKit.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

@interface AppDelegate () <ANHVoIPNotificationHubDelegate, CXProviderDelegate>

@property (nonatomic, strong) PKPushRegistry *pushRegistry;
@property (nonatomic, strong) CXProvider *callProvider;
@property (nonatomic, strong) CXCallController *callController;
@property (nonatomic, strong) NSUUID *currentCall;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.pushRegistry = [[PKPushRegistry alloc] initWithQueue:nil];
    self.pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    self.pushRegistry.delegate = (id)self;
    
    [self configureCallKit];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DevSettings" ofType:@"plist"];
    NSDictionary *configValues = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *connectionString = [configValues objectForKey:@"CONNECTION_STRING"];
    NSString *hubName = [configValues objectForKey:@"HUB_NAME"];
    
    NSError *anhError;
    ANHNotificationHub.logLevel = ANHLogLevelDebug;
    [ANHVoIPNotificationHub sharedInstance].delegate = self;
    if (![[ANHVoIPNotificationHub sharedInstance] startWithConnectionString:connectionString hubName:hubName  error:&anhError]) {
        NSLog(@"Error starting the ANH client: %@", anhError.localizedDescription);
        
        exit(-1);
    }
    
    [self addTags];
    
    return YES;
}

// Adds some basic tags such as language and country
- (void)addTags {
    // Get language and country code for common tag values
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString *countryCode = [[NSLocale currentLocale] countryCode];

    // Create tags with type_value format
    NSString *languageTag = [NSString stringWithFormat:@"language_%@", language];
    NSString *countryCodeTag = [NSString stringWithFormat:@"country_%@", countryCode];

    [[ANHVoIPNotificationHub sharedInstance] addTags:@[languageTag, countryCodeTag]];
}

- (void)notificationHub:(ANHVoIPNotificationHub *)notificationHub didReceiveIncomingPushWithPayload:(NSDictionary *)payload withCompletionHandler:(void (^)(void))completionHandler {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppMessageReceived object:nil userInfo:payload];
    
    NSString *handle = @"555-555-1212";
    
    /***/
    NSUUID *callUUID = [[NSUUID alloc] init];
    
    CXCallUpdate *callUpdate = [CXCallUpdate new];
    CXHandle *phoneNumber = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:handle];
    callUpdate.remoteHandle = phoneNumber;
    
    __weak AppDelegate *weakSelf = self;
    
    [self.callProvider reportNewIncomingCallWithUUID:callUUID update:callUpdate completion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error with call %@", error.localizedDescription);
        }
        
        weakSelf.currentCall = callUUID;
        
        NSLog(@"Call complete");
        completionHandler();
    }];
}

- (void) configureCallKit {
    CXProviderConfiguration *config = [[CXProviderConfiguration alloc] initWithLocalizedName:@"VoIP Service"];
    config.supportsVideo = YES;
    config.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypePhoneNumber)];
    config.supportsVideo = YES;
    config.maximumCallsPerCallGroup = 1;
    
    self.callProvider = [[CXProvider alloc] initWithConfiguration:config];
    [self.callProvider setDelegate:self queue:nil];
}

#pragma mark CXProviderDelegate

- (void)providerDidBegin:(CXProvider *)provider {

}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    [self.callProvider reportOutgoingCallWithUUID:action.callUUID startedConnectingAtDate:nil];
    [self.callProvider reportOutgoingCallWithUUID:action.callUUID connectedAtDate:nil];
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    
    self.currentCall = nil;
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
    
    if (action.isOnHold) {
        // TODO: stop audio
    } else {
        // TODO: start audio
    }
    
    [action fulfill];
    
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
    
}

- (void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action {
    
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {

}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
     
 }

- (void)providerDidReset:(nonnull CXProvider *)provider {

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

#pragma mark Helpers

- (NSString *)convertTokenToString:(NSData *)token {
    if (!token) {
        return nil;
    }
    const unsigned char *dataBuffer = token.bytes;
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:(token.length * 2)];
    for (NSUInteger i = 0; i < token.length; ++i) {
        [stringBuffer appendFormat:@"%02x", dataBuffer[i]];
    }
    return [NSString stringWithString:stringBuffer];
}

@end
