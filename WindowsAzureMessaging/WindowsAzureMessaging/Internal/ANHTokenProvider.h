//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANHTokenProvider : NSObject

@property(nonatomic) NSInteger timeToExpireinMins;
+ (instancetype)createFromConnectionDictionary:(NSDictionary *)connectionDictionary;

- (instancetype)initWithConnectionDictionary:(NSDictionary *)connectionDictionary;
- (NSString *)generateSharedAccessTokenWithUrl:(NSString *)audienceUri;
@end

NS_ASSUME_NONNULL_END
