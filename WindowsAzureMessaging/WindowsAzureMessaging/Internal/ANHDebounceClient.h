//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_DEBOUNCE_CLIENT_h
#define ANH_DEBOUNCE_CLIENT_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^InstallationCompletionHandler)(NSError *_Nullable);

typedef void (^InstallationEnrichmentHandler)(void);
typedef void (^InstallationManagementHandler)(InstallationCompletionHandler _Nonnull);

@interface ANHDebounceClient : NSObject

- (instancetype)initWithInterval:(double)interval;

- (void)runPipeline:(InstallationEnrichmentHandler)enrichmentHandler
  managementHandler:(InstallationManagementHandler)managementHandler
  completionHandler:(InstallationCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END

#endif
