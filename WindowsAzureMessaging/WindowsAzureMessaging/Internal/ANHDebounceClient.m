//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHDebounceClient+Private.h"

@implementation ANHDebounceClient

- (instancetype)initWithInterval:(double)interval {
    if ((self = [super init]) != nil) {
        _interval = interval;
    }
    
    return self;
}

- (void)runPipeline:(InstallationEnrichmentHandler)enrichmentHandler
  managementHandler:(InstallationManagementHandler)managementHandler
  completionHandler:(InstallationCompletionHandler)completionHandler {
    if (!_debounceTimer) {
        [_debounceTimer invalidate];
    }
    
    _enrichmentHandler = enrichmentHandler;
    _managementHandler = managementHandler;
    _completionHandler = completionHandler;
    
    _debounceTimer = [NSTimer scheduledTimerWithTimeInterval:_interval
                                                      target:self
                                                    selector:@selector(execute)
                                                    userInfo:nil
                                                     repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:_debounceTimer forMode:NSRunLoopCommonModes];
}

- (void)execute {
    _enrichmentHandler();
    _managementHandler(_completionHandler);
}

@end
