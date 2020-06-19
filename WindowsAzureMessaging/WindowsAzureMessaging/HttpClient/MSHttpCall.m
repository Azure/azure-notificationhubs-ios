// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSHttpCall.h"

@implementation MSHttpCall

- (instancetype)initWithUrl:(NSURL *)url
                     method:(NSString *)method
                    headers:(NSDictionary<NSString *, NSString *> *)headers
                       data:(NSData *)data
             retryIntervals:(NSArray *)retryIntervals
          completionHandler:(MSHttpRequestCompletionHandler)completionHandler {
    if ((self = [super init])) {
        _url = url;
        _method = method;
        _retryIntervals = retryIntervals;
        _completionHandler = completionHandler;
        _retryCount = 0;
        _inProgress = NO;
        _data = data;
        _headers = headers;
    }
    return self;
}

- (BOOL)hasReachedMaxRetries {
    @synchronized(self) {
        return self.retryCount >= (int)[self.retryIntervals count];
    }
}

- (void)resetRetry {
    @synchronized(self) {
        if (self.timerSource) {
            dispatch_source_cancel(self.timerSource);
        }
        self.retryCount = 0;
    }
}

- (void)startRetryTimerWithStatusCode:(NSUInteger)statusCode retryAfter:(NSNumber *)retryAfter event:(dispatch_block_t)event {
    @synchronized(self) {

        // Create queue.
        self.timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, DISPATCH_TARGET_QUEUE_DEFAULT);
        uint32_t millisecondsDelta = retryAfter ? [retryAfter unsignedIntValue] : [self delayForRetryCount:self.retryCount];
        NSLog(@"Call attempt #%d failed with status code: %tu, it will be retried in %d ms.", self.retryCount, statusCode,
              millisecondsDelta); // warning
        uint64_t nanosecondsDelta = NSEC_PER_MSEC * millisecondsDelta;
        self.retryCount++;
        dispatch_source_set_timer(self.timerSource, dispatch_walltime(NULL, nanosecondsDelta), DISPATCH_TIME_FOREVER, 1ull * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timerSource, event);
        dispatch_resume(self.timerSource);
    }
}

- (uint32_t)delayForRetryCount:(NSUInteger)retryCount {

    // Create a random delay.
    uint32_t millisecondsDelay =
        (uint32_t)((NSEC_PER_SEC * [(NSNumber *)self.retryIntervals[retryCount] doubleValue] / 2.0) / (double)NSEC_PER_MSEC);
    millisecondsDelay += arc4random_uniform(millisecondsDelay);
    return millisecondsDelay;
}

@end
