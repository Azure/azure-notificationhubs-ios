//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_CONSTANTS_h
#define ANH_CONSTANTS_h

#import <Foundation/Foundation.h>

/**
 *  Log Levels
 */
typedef NS_ENUM(NSUInteger, ANHLogLevel) {

  /**
   *  Logging will be very chatty
   */
  ANHLogLevelVerbose = 2,

  /**
   *  Debug information will be logged
   */
  ANHLogLevelDebug = 3,

  /**
   *  Information will be logged
   */
  ANHLogLevelInfo = 4,

  /**
   *  Errors and warnings will be logged
   */
  ANHLogLevelWarning = 5,

  /**
   *  Errors will be logged
   */
  ANHLogLevelError = 6,

  /**
   * Only critical errors will be logged
   */
  ANHLogLevelAssert = 7,

  /**
   *  Logging is disabled
   */
  ANHLogLevelNone = 99
} NS_SWIFT_NAME(LogLevel);

typedef NSString * (^ANHLogMessageProvider)(void)NS_SWIFT_NAME(LogMessageProvider);
typedef void (^ANHLogHandler)(ANHLogMessageProvider messageProvider, ANHLogLevel logLevel, NSString *tag, const char *file,
                               const char *function, uint line) NS_SWIFT_NAME(LogHandler);

#endif
