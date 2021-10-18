//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "ANHLogger.h"

FOUNDATION_EXPORT ANHLogHandler const anhDefaultLogHandler;

@interface ANHLogger ()

+ (BOOL)isUserDefinedLogLevel;

/*
 * For testing only.
 */
+ (void)setIsUserDefinedLogLevel:(BOOL)isUserDefinedLogLevel;

+ (ANHLogLevel)currentLogLevel;

+ (ANHLogHandler)logHandler;

+ (void)setCurrentLogLevel:(ANHLogLevel)currentLogLevel;

+ (void)setLogHandler:(ANHLogHandler)logHandler;

@end
