//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSHttpUtil.h"

@implementation MSHttpUtil

+ (BOOL)isRecoverableError:(NSInteger)statusCode {

    // There are some cases when statusCode is 0, e.g., when server is unreachable. If so, the error will contain more details.
    // Legacy behavior for throttling is 403 for NotificationHubs
    return statusCode >= 500 || statusCode == 408 || statusCode == 403 || statusCode == 429 || statusCode == 0;
}

+ (BOOL)isSuccessStatusCode:(NSInteger)statusCode {
    return statusCode >= 200 && statusCode < 300;
}

+ (BOOL)isNoInternetConnectionError:(NSError *)error {
    return ([error.domain isEqualToString:NSURLErrorDomain] &&
            ((error.code == NSURLErrorNotConnectedToInternet) || (error.code == NSURLErrorNetworkConnectionLost)));
}

+ (BOOL)isSSLConnectionError:(NSError *)error {

    // Check for error domain and if the error.code falls in the range of SSL connection errors (between -2000 and -1200).
    return ([error.domain isEqualToString:NSURLErrorDomain] &&
            ((error.code >= NSURLErrorCannotLoadFromNetwork) && (error.code <= NSURLErrorSecureConnectionFailed)));
}

@end
