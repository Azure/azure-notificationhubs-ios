// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSDebounceInstallationManager : NSObject

@property(nonatomic) double interval;
@property(nonatomic) NSTimer *debounceTimer;

- (instancetype)initWithInterval:(double)interval;
- (void)saveInstallation;

@end

NS_ASSUME_NONNULL_END
