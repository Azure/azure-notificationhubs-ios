//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class MSInstallation;
@class MSInstallationTemplate;
@class MSTokenProvider;
@class MSHttpClient;

typedef void (^InstallationEnrichmentHandler)(void);
typedef BOOL (^InstallationManagementHandler)(void);

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
    withManagementHandler:(InstallationManagementHandler)managementHandler;

@end
