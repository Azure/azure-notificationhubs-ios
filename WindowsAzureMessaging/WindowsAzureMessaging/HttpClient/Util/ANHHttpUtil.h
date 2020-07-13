//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface ANHHttpUtil : NSObject

/**
 * Indicate if the http response is recoverable.
 *
 * @param statusCode Http status code.
 *
 * @return YES if it is recoverable.
 */
+ (BOOL)isRecoverableError:(NSInteger)statusCode;

/**
 * Indicate if the http response is a success response.
 *
 * @param statusCode Http status code.
 *
 * @return YES if it is a success code.
 */
+ (BOOL)isSuccessStatusCode:(NSInteger)statusCode;

/**
 * Indicate if error is due to no internet connection.
 *
 * @param error http error.
 *
 * @return YES if it is a no network connection error, NO otherwise.
 */
+ (BOOL)isNoInternetConnectionError:(NSError *)error;

/**
 * Indicate if error is because a secure connection could not be established, e.g. when using a public network that * is open but requires
 * accepting terms and conditions, and the user hasn't done that, yet.
 *
 * @param error http error.
 *
 * @return YES if it is an SSL connection error, NO otherwise.
 */
+ (BOOL)isSSLConnectionError:(NSError *)error;

@end
