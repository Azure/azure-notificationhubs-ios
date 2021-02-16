//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHTaggable.h"
#import <Foundation/Foundation.h>

/**
 * Represents an installation template.
 */
@interface ANHInstallationTemplate : NSObject <ANHTaggable>

/**
 * The template body for notification payload which may contain placeholders to be filled in with actual data during the send operation
 */
@property(nonatomic, copy) NSString *body;

/**
 * A collection of headers applicable for MPNS-targeted notifications
 */
@property(nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *headers;

/**
 * Sets the header key and value.
 *
 * @param value The value of the header
 * @param key The name of the header.
 */
- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key;

/**
 * Removes the header for the given key.
 *
 * @param key The header to remove based upon the key.
 */
- (void)removeHeaderValueForKey:(NSString *)key;

/**
 * Gets the header value based upon the key.
 *
 * @param key The name of the header
 *
 * @returns The value of the header.
 */
- (NSString *)headerValueForKey:(NSString *)key;

/**
 * Creates a dictionary representation of the installation template.
 *
 * @returns The installation templates in dictionary form.
 */
- (NSDictionary *)toDictionary;

@end
