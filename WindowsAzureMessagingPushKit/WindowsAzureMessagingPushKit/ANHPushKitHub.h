//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "ANHPushKitHubDelegate.h"
#import "ANHPushKitHubOptions.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(PushKitHub)
@interface ANHPushKitHub : NSObject

#pragma mark Initialization

+ (void)startWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName options:(ANHPushKitHubOptions *)options NS_SWIFT_NAME(start(connectionString:hubName:options:));

#pragma mark Properties

@property (class, readonly, nullable, nonatomic, copy) installationId;

@property (class, readonly, nullable, nonatomic, copy) pushChannel;

#pragma mark Delegates

@property(readwrite, weak, nullable) id<ANHPushKitHubDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
