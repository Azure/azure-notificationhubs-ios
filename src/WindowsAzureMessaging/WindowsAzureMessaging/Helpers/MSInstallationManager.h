//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class MSInstallation;
@class MSTokenProvider;
@class MSHttpClient;

@interface MSInstallationManager : NSObject {

  @private
    MSTokenProvider *tokenProvider;
    NSDictionary *connectionDictionary;
    NSString *pushToken;
}

@property(nonatomic) MSHttpClient *httpClient;

+ (void)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName;

+ (void)saveInstallation;
+ (void)setPushChannel:(NSString *)pushChannel;
+ (BOOL)addTags:(NSSet<NSString *> *)tags;
+ (BOOL)removeTags:(NSSet<NSString *> *)tags;
+ (NSSet<NSString *> *)getTags;
+ (void)clearTags;
+ (MSInstallation *)getInstallation;
+ (void)setHttpClient:(MSHttpClient *)client;

- (void)saveInstallation;
+ (void)resetInstance;

@end
