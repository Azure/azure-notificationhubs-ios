//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MSInstallation;
@class MSInstallationTemplate;
@class MSTokenProvider;
@class MSHttpClient;

typedef void (^InstallationEnrichmentHandler)(void);
typedef BOOL (^InstallationManagementHandler)(void);
typedef void (^InstallationCompletionHandler)(NSError * _Nullable);

@interface MSInstallationManager : NSObject {
  @private
    NSString *_connectionString;
    NSString *_hubName;
    MSTokenProvider *_tokenProvider;
    NSDictionary *_connectionDictionary;
}

@property(nonatomic) MSHttpClient *httpClient;

- (instancetype)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName;
- (void)saveInstallation:(MSInstallation *)installation
    withEnrichmentHandler:(InstallationEnrichmentHandler)enrichmentHandler
    withManagementHandler:(InstallationManagementHandler)managementHandler
    completionHandler:(InstallationCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
