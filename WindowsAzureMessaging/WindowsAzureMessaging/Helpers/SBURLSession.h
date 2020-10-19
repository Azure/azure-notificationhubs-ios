//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface SBURLSession : NSObject

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse * __autoreleasing*)response error:(NSError * __autoreleasing*)error;

+ (void)sendRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * data, NSURLResponse *response, NSError *error))completionHandler;

@end
