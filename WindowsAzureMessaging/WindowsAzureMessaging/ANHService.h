//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_ABSTRACT_SERVICE_H
#define ANH_ABSTRACT_SERVICE_H

#import <Foundation/Foundation.h>
#import "ANHConstants.h"
#import "ANHInstallationEnrichmentDelegate.h"
#import "ANHInstallationLifecycleDelegate.h"
#import "ANHInstallationManagementDelegate.h"

@class ANHInstallation;
@class ANHInstallationTemplate;

NS_ASSUME_NONNULL_BEGIN

@interface ANHService : NSObject

#pragma mark - Installation Support

/**
 * The current push channel device token.
 */
@property (nonatomic, readonly, nullable) NSString *pushChannel;

/**
 * The current installation ID.
 */
@property (nonatomic, readonly, nullable) NSString *installationId;

#pragma mark Tags Support

/**
 * Adds a tag to the current installation.
 *
 * @param tag The tag to add
 *
 * @returns YES if tag was added, else NO.
 */
- (BOOL)addTag:(NSString *)tag;

/**
 * Adds the tags array to the current installation.
 *
 * @param tags The tags array to add
 *
 * @returns YES if the tags were added, else NO.
 */
- (BOOL)addTags:(NSArray<NSString *> *)tags;

/**
 * Removes the tag from the current installation.
 *
 * @param tag The tag to remove.
 *
 * @returns YES if the tag was removed, else NO.
 */
- (BOOL)removeTag:(NSString *)tag;

/**
 * Removes the tags from the current installation.
 *
 * @param tags The tags to remove.
 *
 * @returns YES if the tags were removed, else NO.
 */
- (BOOL)removeTags:(NSArray<NSString *> *)tags;

/**
 * The tags from the current installation.
 */
@property (nonatomic, nullable, readonly) NSArray<NSString *> * tags;

/**
 * Clears the tags from the current installation.
 */
- (void)clearTags;

#pragma mark Template Support

/**
 * Sets the template for the installation template for the given key.
 *
 * @param template The `ANHInstallationTemplate` object containing the installation template data.
 * @param key The key for the template.
 *
 * @returns YES if the template was added, else NO.
 *
 * @see ANHInstallationTemplate
 */
- (BOOL)setTemplate:(ANHInstallationTemplate *)template forKey:(NSString *)key;

/**
 * Removes the installation template for the given key.
 *
 * @param key The key for the inistallation template.
 *
 * @returns YES if removed, else NO.
 */
- (BOOL)removeTemplateForKey:(NSString *)key;

/**
 * Gets the installation template `ANHInstallationTemplate` for the given key.
 *
 * @param key The key for the template.
 *
 * @returns The installation template instance
 *
 * @see ANHInstallationTemplate
 */
- (nullable ANHInstallationTemplate *)templateForKey:(NSString *)key;

/**
 * Gets all the templates for the given installation.
 * @see ANHInstallationTemplate
 */
@property (nonatomic, nullable, readonly) NSDictionary<NSString *, ANHInstallationTemplate *> * templates;

#pragma mark UserID support

/**
 * Represents the User ID for the application
 */
@property (nonatomic, copy) NSString *userId;

#pragma mark Installation management support

/**
 * The delegate for getting enriching installations before saving to the backend.
 */
@property(nonatomic, weak) id<ANHInstallationEnrichmentDelegate> _Nullable enrichmentDelegate;

/**
 * The lifecycle delegate to be able to intercept whether saving the installation was successful.
 * Defines the class that implements the optional protocol `ANHInstallationLifecycleDelegate`.
 */
@property(nonatomic, weak) id<ANHInstallationLifecycleDelegate> _Nullable lifecycleDelegate;

#pragma mark - Support

/**
 * The SDK's log level.
 */
@property(class, nonatomic) ANHLogLevel logLevel;

/**
 * Set log handler.
 */
@property(class, nonatomic) ANHLogHandler logHandler;

@end

NS_ASSUME_NONNULL_END

#endif
