//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "SBURLSession.h"
#import "SBURLSession+Private.h"

@implementation SBURLSession

static StaticHandleBlock _staticHandler;

+ (void)setStaticHandler:(StaticHandleBlock)staticHandler {
    _staticHandler = staticHandler;
}

+ (void)sendRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    
    if (_staticHandler) {
        SBStaticHandlerResponse *mockResponse = _staticHandler(request);
        if (mockResponse) {
            NSURL *requestURL = [request URL];
            NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:requestURL
                 statusCode:200
                HTTPVersion:nil
               headerFields:mockResponse.Headers];
            
            completionHandler(mockResponse.Data, response, nil);
        }
        
        return;
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler] resume];
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse *__autoreleasing *)response error:(NSError *__autoreleasing *)error {
    
    if (_staticHandler != nil) {
        SBStaticHandlerResponse *mockResponse = _staticHandler(request);
        if (mockResponse != nil) {
            NSURL *requestURL = [request URL];
            *response = [[NSHTTPURLResponse alloc] initWithURL:requestURL
                                                    statusCode:200
                                                    HTTPVersion:nil
                                                   headerFields:mockResponse.Headers];

            return mockResponse.Data;
        }
        
        return nil;
    }
    
    __block NSData *resultData = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable res, NSError * _Nullable err) {
        
        resultData = data;
        *response = res;
        *error = err;
        
        dispatch_semaphore_signal(semaphore);
    }] resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return resultData;
}

@end
