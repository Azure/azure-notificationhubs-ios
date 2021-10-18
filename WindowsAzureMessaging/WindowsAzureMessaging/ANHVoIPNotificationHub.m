//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHVoIPNotificationHub+Private.h"
#import "ANHAsync.h"
#import "ANHDebounceClient.h"
#import "ANHDelegateForwarder.h"
#import "ANHLocalStorage.h"
#import "ANHLogger+Private.h"
#import "ANHPushRegistryDelegateForwarder.h"
#import "ANH_Errors.h"

#import "ANHNotificationHubAppDelegateForwarder.h"
#import "ANHUserNotificationCenterDelegateForwarder.h"

static NSString * const kANHDummyDeviceToken = @"00fc13adff785122b4ad28809a3420982341241421348097878e577c991de8f0";

@implementation ANHVoIPNotificationHub

#pragma mark - Singleton

// Singleton
static ANHVoIPNotificationHub *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
      if (sharedInstance == nil) {
          sharedInstance = [self new];
      }
    });
    return sharedInstance;
}

+ (void)resetSharedInstance {
    // Resets the once_token so dispatch_once will run again
    onceToken = 0;
    sharedInstance = nil;
}

#pragma mark - Initialization

- (instancetype)init {
    if ((self = [super init])) {
        // TODO: swizzle PKPushRegistry?
        self.debounceClient = [[ANHDebounceClient alloc] initWithInterval: 2];
    }
    
    return self;
}

- (BOOL)startWithConnectionString:(NSString *)connectionString
                          hubName:(NSString *)hubName
                            error:(NSError * __autoreleasing *)error {
    PKPushRegistry *registry = [[PKPushRegistry alloc] initWithQueue:nil];
    return [self startWithConnectionString:connectionString hubName:hubName pushRegistry:registry error:error];
}

- (BOOL)startWithConnectionString:(NSString *)connectionString
                          hubName:(NSString *)hubName
                     pushRegistry:(PKPushRegistry *)registry
                            error:(NSError * __autoreleasing *)error {
    ANHConnection *connection = [[ANHConnection alloc] initWithConnectionString:connectionString];
    if (!connection) {
        if (error) {
            NSDictionary *userInfo = @{
               NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid connection string.", nil),
               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Invalid connection string format.", nil),
               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Invalid connection string. Check the format of the connection string.", nil)
            };
            *error = [NSError errorWithDomain:kANHErrorDomain code:ANHConnectionErrorCode userInfo:userInfo];
            ANHLogError(kANHLogDomain, @"Invalid connection string");
            return NO;
        }
    }
    
    self.connectionString = connection;
    self.installationClient = [[ANHInstallationClient alloc] initWithConnectionString:connection hubName:hubName];
    self.pushRegistry = registry;
    self.pushRegistry.delegate = self;
    self.pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    return YES;
}

- (void)startWithInstallationManagement:(id<ANHInstallationManagementDelegate>)managementDelegate {
    PKPushRegistry *registry = [[PKPushRegistry alloc] initWithQueue:nil];
    [self startWithInstallationManagement:managementDelegate pushRegistry:registry];
}

- (void)startWithInstallationManagement:(id<ANHInstallationManagementDelegate>)managementDelegate
                           pushRegistry:(PKPushRegistry *)registry {
    self.managementDelegate = managementDelegate;
    self.pushRegistry = registry;
    self.pushRegistry.delegate = self;
    self.pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

#pragma mark - PKPushRegistryDelegate

- (void)didUpdatePushCredentials:(NSData *)pushCredentials {
    NSString *pushToken = [self convertTokenToString:pushCredentials];
    ANHLogInfo(kANHLogDomain, @"Registered for push notifications with token: %@", pushToken);

    ANHInstallation *installation = [self installation];

    if ([pushToken isEqualToString:installation.pushChannel]) {
        return;
    }

    installation.pushChannel = pushToken;
    self.pushChannel = pushToken;
    [self upsertInstallation:installation];
}

- (void)didInvalidatePushToken {
    self.installation.pushChannel = kANHDummyDeviceToken;
    self.pushChannel = kANHDummyDeviceToken;
    [self upsertInstallation:self.installation];
}

- (void)didReceiveIncomingPushWithPayload:(NSDictionary *)payload
                    withCompletionHandler:(void (^)(void))completion ANH_SWIFT_DISABLE_ASYNC {
    dispatch_async(dispatch_get_main_queue(), ^{
        id<ANHVoIPNotificationHubDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(notificationHub:didReceiveIncomingPushWithPayload:withCompletionHandler:)]) {
            [delegate notificationHub:self didReceiveIncomingPushWithPayload:payload withCompletionHandler:completion];
        }
    });
}

#pragma mark - ANHService Implementation

- (NSString *)currentInstallationKey {
    return kANHVoIPInstallationKey;
}

- (NSString *)lastInstallationKey {
    return kANHVoIPLastInstallationKey;
}

#pragma mark - PKPushRegistryDelegate

- (void)pushRegistry:(PKPushRegistry *)registry
didUpdatePushCredentials:(PKPushCredentials *)pushCredentials
             forType:(PKPushType)type {
    [self didUpdatePushCredentials:pushCredentials.token];
}

- (void)pushRegistry:(PKPushRegistry *)registry
didInvalidatePushTokenForType:(PKPushType)type {
    [self didInvalidatePushToken];
}

- (void)pushRegistry:(PKPushRegistry *)registry
didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
             forType:(PKPushType)type
withCompletionHandler:(void (^)(void))completion {
    [self didReceiveIncomingPushWithPayload:payload.dictionaryPayload withCompletionHandler:completion];
}

@end
