//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "SBStaticHandlerResponse.h"
#import <Foundation/Foundation.h>

typedef void (^SBURLConnectionCompletion)(NSHTTPURLResponse *, NSData *, NSError *);
typedef SBStaticHandlerResponse * (^StaticHandleBlock)(NSURLRequest *);

@interface SBURLConnection : NSObject {
  @private
    NSURLRequest *_request;
    NSHTTPURLResponse *_response;
    SBURLConnectionCompletion _completion;
    NSMutableData *_data;
}

- (void)sendRequest:(NSURLRequest *)request completion:(void (^)(NSHTTPURLResponse *, NSData *, NSError *))completion;

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;

+ (void)setStaticHandler:(StaticHandleBlock)staticHandler;

@end
