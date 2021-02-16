//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ANHPushKitHub

@protocol ANHPushKitHubDelegate <NSObject>

@optional

- (void)pushKitHub:(ANHPushKitHub *)hub didReceiveIncomingPushWithPayload:(PKPushPayload *)payload
                              forType:(PKPushType)type
                withCompletionHandler:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
