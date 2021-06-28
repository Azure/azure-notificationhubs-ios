#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTokenProvider : NSObject

@property(nonatomic) NSInteger timeToExpireinMins;
- (instancetype)initWithConnectionDictionary:(NSDictionary *)connectionDictionary;
- (NSString *)generateSharedAccessTokenWithUrl:(NSString *)audienceUri;
@end

NS_ASSUME_NONNULL_END
