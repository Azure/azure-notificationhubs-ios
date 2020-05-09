//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@class MSInstallation;
@class MSInstallationManager;

NS_ASSUME_NONNULL_BEGIN

@interface MSDebounceInstallationManager : NSObject {
    @private
    double _interval;
    NSTimer *_debounceTimer;
    MSInstallationManager *_installationManager;
}

- (instancetype)initWithInterval:(double)interval installationManager:(MSInstallationManager *)installationManager;
- (void)saveInstallation:(MSInstallation *)installation;

@end

NS_ASSUME_NONNULL_END
