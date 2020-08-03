//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "SBStaticHandlerResponse.h"
#import <Foundation/Foundation.h>

typedef void (^SBURLConnectionCompletion)(NSHTTPURLResponse *, NSData *, NSError *);
typedef SBStaticHandlerResponse * (^StaticHandleBlock)(NSURLRequest *);

@interface SBURLConnection : NSObject {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-interface-ivars"
  @private
    NSURLRequest *_request;
    NSHTTPURLResponse *_response;
    SBURLConnectionCompletion _completion;
    NSMutableData *_data;
}

#pragma GCC diagnostic pop

- (void)sendRequest:(NSURLRequest *)request completion:(void (^)(NSHTTPURLResponse *, NSData *, NSError *))completion;

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;

+ (void)setStaticHandler:(StaticHandleBlock)staticHandler;

@end
