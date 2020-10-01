//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "AppDelegate.h"
#import <PushKit/PushKit.h>
#import <CallKit/CallKit.h>

@interface AppDelegate () <PKPushRegistryDelegate, CXProviderDelegate>

@property (nonatomic, strong) PKPushRegistry *voipRegistry;
@property (nonatomic, strong) NSString *voipToken;
@property (nonatomic, strong) CXProvider *callProvider;
@property (nonatomic, strong) CXCallController *callController;
@property (nonatomic, strong) NSUUID *currentCall;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self registerForVoIPPushes];
    [self configureCallKit];
    
    return YES;
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

- (void) registerForVoIPPushes {
   self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:nil];
   self.voipRegistry.delegate = self;
 
   // Initiate registration.
   self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
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

#pragma mark PKPushRegistry

- (void)pushRegistry:(PKPushRegistry *)registry
didUpdatePushCredentials:(PKPushCredentials *)pushCredentials
             forType:(PKPushType)type {
    NSData *pushToken = pushCredentials.token;
    NSString *voipTokenString = [self convertTokenToString:pushToken];
    self.voipToken = voipTokenString;
    NSLog(@"Registered with token: %@", voipTokenString);
}

- (void)pushRegistry:(PKPushRegistry *)registry
didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
             forType:(PKPushType)type
withCompletionHandler:(void (^)(void))completion {

    if (type == PKPushTypeVoIP) {
        NSString *handle = [payload.dictionaryPayload objectForKey:@"handle"];
        NSString *uuidString = [payload.dictionaryPayload objectForKey:@"callUUID"];
        
        /***/
        NSUUID *callUUID = [[NSUUID alloc] initWithUUIDString:uuidString];
        
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
            completion();
        }];
    }
    
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
