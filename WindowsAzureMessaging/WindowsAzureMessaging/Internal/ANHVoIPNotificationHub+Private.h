//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHVoIPNotificationHub.h"
#import "ANHService+Private.h"

@interface ANHVoIPNotificationHub () <PKPushRegistryDelegate>

@property (nonatomic, strong) PKPushRegistry *pushRegistry;

- (void)pushRegistry:(PKPushRegistry *)registry
didUpdatePushCredentials:(PKPushCredentials *)pushCredentials
             forType:(PKPushType)type;

- (void)pushRegistry:(PKPushRegistry *)registry
didInvalidatePushTokenForType:(PKPushType)type;

- (void)pushRegistry:(PKPushRegistry *)registry
didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
             forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion;

@end
