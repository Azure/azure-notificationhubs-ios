//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(PushKitHubOptions)
@interface ANHPushKitHubOptions : NSObject

- (instancetype)initWithDesiredPushTypes:(NSSet<PKPushType> *)pushTypes;

@property(readwrite, copy, nullable) NSSet<PKPushType> *desiredPushTypes;

@end

NS_ASSUME_NONNULL_END
