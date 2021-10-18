//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHLogger+Private.h"

@implementation ANHLogger

static ANHLogLevel _currentLogLevel = ANHLogLevelAssert;
static ANHLogHandler currentLogHandler;
static BOOL _isUserDefinedLogLevel = NO;

ANHLogHandler const anhDefaultLogHandler = ^(ANHLogMessageProvider messageProvider, ANHLogLevel logLevel, NSString *tag, __attribute__((unused)) const char *file, const char *function, uint line) {
    if (messageProvider) {
        if (_currentLogLevel > logLevel) {
            return;
        }
        
        NSString *level;
        switch (logLevel) {
            case ANHLogLevelVerbose:
                level = @"VERBOSE";
                break;
            case ANHLogLevelDebug:
                level = @"DEBUG";
                break;
            case ANHLogLevelInfo:
                level = @"INFO";
                break;
            case ANHLogLevelWarning:
                level = @"WARNING";
                break;
            case ANHLogLevelError:
                level = @"ERROR";
                break;
            case ANHLogLevelAssert:
                level = @"ASSERT";
                break;
            case ANHLogLevelNone:
                return;
        }
        
        NSLog(@"[%@] %@: %@/%d %@", tag, level, [NSString stringWithCString:function encoding:NSUTF8StringEncoding], line, messageProvider());
    }
};

+ (void)initialize {
    currentLogHandler = anhDefaultLogHandler;
}

+ (ANHLogLevel)currentLogLevel {
    @synchronized(self) {
        return _currentLogLevel;
    }
}

+ (ANHLogHandler)logHandler {
    @synchronized(self) {
        return currentLogHandler;
    }
}

+ (void)setCurrentLogLevel:(ANHLogLevel)currentLogLevel {
    @synchronized(self) {
        _isUserDefinedLogLevel = YES;
        _currentLogLevel = currentLogLevel;
    }
}

+ (void)setLogHandler:(ANHLogHandler)logHandler {
    @synchronized(self) {
        _isUserDefinedLogLevel = YES;
        currentLogHandler = logHandler;
    }
}

+ (void)logMessage:(ANHLogMessageProvider)messageProvider
             level:(ANHLogLevel)loglevel
               tag:(NSString *)tag
              file:(const char *)file
          function:(const char *)function
              line:(uint)line {
    if (currentLogHandler) {
        currentLogHandler(messageProvider, loglevel, tag, file, function, line);
    }
}

+ (BOOL)isUserDefinedLogLevel {
    return _isUserDefinedLogLevel;
}

+ (void)setIsUserDefinedLogLevel:(BOOL)isUserDefinedLogLevel {
    _isUserDefinedLogLevel = isUserDefinedLogLevel;
}

@end
