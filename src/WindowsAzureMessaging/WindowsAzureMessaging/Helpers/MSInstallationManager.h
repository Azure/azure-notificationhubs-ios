//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class MSInstallation;
@class MSInstallationTemplate;
@class MSTokenProvider;
@class MSHttpClient;

@interface MSInstallationManager : NSObject {

  @private
    NSString *_connectionString;
    NSString *_hubName;
    MSTokenProvider *_tokenProvider;
    NSDictionary *_connectionDictionary;
}

@property(nonatomic) MSHttpClient *httpClient;

- (instancetype)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName;
- (void)saveInstallation:(MSInstallation *)installation;

#pragma mark For Testing

- (void)setHttpClient:(MSHttpClient *)httpClient;

@end
