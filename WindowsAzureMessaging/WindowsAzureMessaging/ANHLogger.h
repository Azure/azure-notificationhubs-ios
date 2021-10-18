//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "ANHConstants.h"

#ifndef ANHLogger_h
#define ANHLogger_h

#define ANHLog(_level, _tag, _message)                                                                                                    \
  [ANHLogger logMessage:_message level:_level tag:_tag file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__]
#define ANHLogAssert(tag, format, ...)                                                                                                    \
  ANHLog(ANHLogLevelAssert, tag, (^{                                                                                                     \
            return [NSString stringWithFormat:(format), ##__VA_ARGS__];                                                                    \
          }))
#define ANHLogError(tag, format, ...)                                                                                                     \
  ANHLog(ANHLogLevelError, tag, (^{                                                                                                      \
            return [NSString stringWithFormat:(format), ##__VA_ARGS__];                                                                    \
          }))
#define ANHLogWarning(tag, format, ...)                                                                                                   \
  ANHLog(ANHLogLevelWarning, tag, (^{                                                                                                    \
            return [NSString stringWithFormat:(format), ##__VA_ARGS__];                                                                    \
          }))
#define ANHLogInfo(tag, format, ...)                                                                                                      \
  ANHLog(ANHLogLevelInfo, tag, (^{                                                                                                       \
            return [NSString stringWithFormat:(format), ##__VA_ARGS__];                                                                    \
          }))
#define ANHLogDebug(tag, format, ...)                                                                                                     \
  ANHLog(ANHLogLevelDebug, tag, (^{                                                                                                      \
            return [NSString stringWithFormat:(format), ##__VA_ARGS__];                                                                    \
          }))
#define ANHLogVerbose(tag, format, ...)                                                                                                   \
  ANHLog(ANHLogLevelVerbose, tag, (^{                                                                                                    \
            return [NSString stringWithFormat:(format), ##__VA_ARGS__];                                                                    \
          }))

NS_SWIFT_NAME(Logger)
@interface ANHLogger : NSObject

+ (void)logMessage:(ANHLogMessageProvider)messageProvider
             level:(ANHLogLevel)loglevel
               tag:(NSString *)tag
              file:(const char *)file
          function:(const char *)function
              line:(uint)line;

@end

#endif /* ANHLogger_h */
