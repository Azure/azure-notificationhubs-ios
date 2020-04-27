// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSHttpClient.h"
#import "MSAppCenterErrors.h"
#import "MSConstants+Internal.h"
#import "MSHttpCall.h"
#import "MSHttpClientDelegate.h"
#import "MSHttpClientPrivate.h"
#import "MSHttpUtil.h"
#import "MS_Reachability.h"

#define DEFAULT_RETRY_INTERVALS @[ @10, @(5 * 60), @(20 * 60) ]

#define MS_NOTIFICATION_CENTER [NSNotificationCenter defaultCenter]

@implementation MSHttpClient

@synthesize delegate = _delegate;

- (instancetype)init {
  return [self initWithMaxHttpConnectionsPerHost:nil reachability:[MS_Reachability reachabilityForInternetConnection]];
}

- (instancetype)initWithMaxHttpConnectionsPerHost:(NSInteger)maxHttpConnectionsPerHost {
  return [self initWithMaxHttpConnectionsPerHost:@(maxHttpConnectionsPerHost)
                                    reachability:[MS_Reachability reachabilityForInternetConnection]];
}

- (instancetype)initWithMaxHttpConnectionsPerHost:(NSNumber *)maxHttpConnectionsPerHost reachability:(MS_Reachability *)reachability {
  if ((self = [super init])) {
    _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (maxHttpConnectionsPerHost) {
      _sessionConfiguration.HTTPMaximumConnectionsPerHost = [maxHttpConnectionsPerHost integerValue];
    }
    _session = [NSURLSession sessionWithConfiguration:_sessionConfiguration];
    _pendingCalls = [NSMutableSet new];
    _enabled = YES;
    _paused = NO;
    _reachability = reachability;
    _delegate = nil;

    // Add listener to reachability.
    [MS_NOTIFICATION_CENTER addObserver:self selector:@selector(networkStateChanged:) name:kMSReachabilityChangedNotification object:nil];
    [self.reachability startNotifier];
  }
  return self;
}

- (void)sendAsync:(NSURL *)url
               method:(NSString *)method
              headers:(nullable NSDictionary<NSString *, NSString *> *)headers
                 data:(nullable NSData *)data
    completionHandler:(MSHttpRequestCompletionHandler)completionHandler {
  [self sendAsync:url
                  method:method
                 headers:headers
                    data:data
          retryIntervals:DEFAULT_RETRY_INTERVALS
      compressionEnabled:YES
       completionHandler:completionHandler];
}

- (void)sendAsync:(NSURL *)url
                method:(NSString *)method
               headers:(nullable NSDictionary<NSString *, NSString *> *)headers
                  data:(nullable NSData *)data
        retryIntervals:(NSArray *)retryIntervals
    compressionEnabled:(BOOL)compressionEnabled
     completionHandler:(MSHttpRequestCompletionHandler)completionHandler {
  @synchronized(self) {
    if (!self.enabled) {
      NSError *error = [NSError errorWithDomain:kMSACErrorDomain
                                           code:MSACDisabledErrorCode
                                       userInfo:@{NSLocalizedDescriptionKey : kMSACDisabledErrorDesc}];
      completionHandler(nil, nil, error);
      return;
    }
    MSHttpCall *call = [[MSHttpCall alloc] initWithUrl:url
                                                method:method
                                               headers:headers
                                                  data:data
                                        retryIntervals:retryIntervals
                                    compressionEnabled:compressionEnabled
                                     completionHandler:completionHandler];
    [self sendCallAsync:call];
  }
}

- (void)sendCallAsync:(MSHttpCall *)call {
  @synchronized(self) {
    if (![self.pendingCalls containsObject:call]) {
      [self.pendingCalls addObject:call];
    }
    if (self.paused) {
      return;
    }

    // Call delegate before sending HTTP request.
    id<MSHttpClientDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(willSendHTTPRequestToURL:withHeaders:)]) {
      [strongDelegate willSendHTTPRequestToURL:call.url withHeaders:call.headers];
    }

    // Send HTTP request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:call.url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:0];
    request.HTTPBody = call.data;
    request.HTTPMethod = call.method;
    request.allHTTPHeaderFields = call.headers;

    // Always disable cookies.
    [request setHTTPShouldHandleCookies:NO];
    call.inProgress = YES;
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                   [self requestCompletedWithHttpCall:call data:data response:response error:error];
                                                 }];
    [task resume];
  }
}

- (void)requestCompletedWithHttpCall:(MSHttpCall *)httpCall data:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
  NSHTTPURLResponse *httpResponse;
  @synchronized(self) {
    httpCall.inProgress = NO;

    // If the call was removed, do not invoke the completion handler as that will have been done already by set enabled.
    if (![self.pendingCalls containsObject:httpCall]) {
      NSLog(@"HTTP call was canceled; do not process further."); //debug
      return;
    }

    // Handle NSError (low level error where we don't even get a HTTP response).
    BOOL internetIsDown = [MSHttpUtil isNoInternetConnectionError:error];
    BOOL couldNotEstablishSecureConnection = [MSHttpUtil isSSLConnectionError:error];
    if (error) {
      if (internetIsDown || couldNotEstablishSecureConnection) {

        // Reset the retry count, will retry once the (secure) connection is established again.
        [httpCall resetRetry];
        NSString *logMessage = internetIsDown ? @"Internet connection is down." : @"Could not establish secure connection.";
        NSLog(@"HTTP call failed with error: %@", logMessage); //info
        return;
      } else {
        NSLog(@"HTTP request error with code: %td, domain: %@, description: %@", error.code, error.domain,
                   error.localizedDescription); //error
      }
    }

    // Handle HTTP error.
    else {
      httpResponse = (NSHTTPURLResponse *)response;
      if ([MSHttpUtil isRecoverableError:httpResponse.statusCode]) {
        if ([httpCall hasReachedMaxRetries]) {
          [self pause];
        } else {

          // Check if there is a "retry after" header in the response
          NSString *retryAfter = httpResponse.allHeaderFields[kMSRetryHeaderKey];
          NSNumber *retryAfterMilliseconds;
          if (retryAfter) {
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            retryAfterMilliseconds = [formatter numberFromString:retryAfter];
          }
          [httpCall startRetryTimerWithStatusCode:httpResponse.statusCode
                                       retryAfter:retryAfterMilliseconds
                                            event:^{
                                              [self sendCallAsync:httpCall];
                                            }];
          return;
        }
      } else if (![MSHttpUtil isSuccessStatusCode:httpResponse.statusCode]) {

        // Removing the call from pendingCalls and invoking completion handler must be done before disabling to avoid duplicate invocations.
        [self.pendingCalls removeObject:httpCall];

        // Unblock the caller now with the outcome of the call.
        httpCall.completionHandler(data, httpResponse, error);
        [self setEnabled:NO andDeleteDataOnDisabled:YES];

        // Return so as not to re-invoke completion handler.
        return;
      }
    }
    [self.pendingCalls removeObject:httpCall];
  }

  // Unblock the caller now with the outcome of the call.
  httpCall.completionHandler(data, httpResponse, error);
}

- (void)networkStateChanged:(__unused NSNotificationCenter *)notification {
  if ([self.reachability currentReachabilityStatus] == NotReachable) {
      NSLog(@"Internet connection is down."); //info
    [self pause];
  } else {
    NSLog(@"Internet connection is up."); //info
    [self resume];
  }
}

- (void)pause {
  @synchronized(self) {
    if (self.paused) {
      return;
    }
    NSLog(@"Pause HTTP client."); //info
    self.paused = YES;

    // Reset retry for all calls.
    for (MSHttpCall *call in self.pendingCalls) {
      [call resetRetry];
    }
  }
}

- (void)resume {
  @synchronized(self) {

    // Resume only while enabled.
    if (self.paused && self.enabled) {
      NSLog(@"Resume HTTP client."); //info
      self.paused = NO;

      // Resume calls.
      for (MSHttpCall *call in self.pendingCalls) {
        if (!call.inProgress) {
          [self sendCallAsync:call];
        }
      }
    }
  }
}

- (void)setEnabled:(BOOL)isEnabled andDeleteDataOnDisabled:(BOOL)deleteData {
  @synchronized(self) {
    if (self.enabled != isEnabled) {
      self.enabled = isEnabled;
      if (isEnabled) {
        self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration];
        [self.reachability startNotifier];
        [self resume];
      } else {
        [self.reachability stopNotifier];
        [self pause];
        if (deleteData) {

          // Cancel all the tasks and invalidate current session to free resources.
          [self.session invalidateAndCancel];
          self.session = nil;

          // Remove pending calls and invoke their completion handler.
          for (MSHttpCall *call in self.pendingCalls) {
            NSError *error = [NSError errorWithDomain:kMSACErrorDomain
                                                 code:MSACCanceledErrorCode
                                             userInfo:@{NSLocalizedDescriptionKey : kMSACCanceledErrorDesc}];
            call.completionHandler(nil, nil, error);
          }
          [self.pendingCalls removeAllObjects];
        }
      }
    }
  }
}

- (void)dealloc {
  [self.reachability stopNotifier];
  [MS_NOTIFICATION_CENTER removeObserver:self name:kMSReachabilityChangedNotification object:nil];
  [self.session finishTasksAndInvalidate];
}

@end
