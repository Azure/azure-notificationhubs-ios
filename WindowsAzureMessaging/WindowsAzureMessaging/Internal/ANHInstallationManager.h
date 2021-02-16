//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ANHInstallation;
@class ANHInstallationTemplate;
@class ANHTokenProvider;

typedef void (^InstallationCompletionHandler)(NSError *_Nullable);

typedef void (^InstallationEnrichmentHandler)(void);
typedef BOOL (^InstallationManagementHandler)(InstallationCompletionHandler _Nonnull);

@interface ANHInstallationManager : NSObject

- (instancetype)init;
- (instancetype)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName;
- (void)saveInstallation:(ANHInstallation *)installation
    withEnrichmentHandler:(InstallationEnrichmentHandler)enrichmentHandler
    withManagementHandler:(InstallationManagementHandler)managementHandler
        completionHandler:(InstallationCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
