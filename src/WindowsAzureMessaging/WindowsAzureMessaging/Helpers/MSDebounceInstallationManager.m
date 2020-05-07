// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSDebounceInstallationManager.h"
#import "MSInstallationManager.h"
#import "MSLocalStorage.h"

@implementation MSDebounceInstallationManager

- (instancetype)initWithInterval:(double)interval {
  if (self = [super init]) {
    self.interval = interval;
  }

  return self;
}

- (void)saveInstallation {
  if (_debounceTimer != nil) {
    [_debounceTimer invalidate];
  }

  MSInstallation *installation = [MSLocalStorage loadInstallation];
  MSInstallation *lastInstallation = [MSLocalStorage loadLastInstallation];

  if (![installation isEqual:lastInstallation]) {
    _debounceTimer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(execute) userInfo:nil repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:_debounceTimer forMode:NSRunLoopCommonModes];
  }
}

- (void)execute {
  [MSInstallationManager saveInstallation];
}

@end
