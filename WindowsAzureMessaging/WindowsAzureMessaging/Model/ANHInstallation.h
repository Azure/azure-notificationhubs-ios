//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHTaggable.h"
#import <Foundation/Foundation.h>

@class ANHInstallationTemplate;

/**
 * The Azure Notification Hubs installation for a given device.
 */
NS_SWIFT_NAME(Installation)
@interface ANHInstallation : NSObject <NSCoding, ANHTaggable>

/**
 * Creates a new Installation from JSON.
 * @param json The JSON data to create the Installation object.
 */
+ (instancetype)createFromJSON:(NSDictionary *)json;

/**
 * The unique identifier for the installation
 */
@property(nonatomic, copy) NSString *installationId;

/**
 * The push token for the APNS Service
 */
@property(nonatomic, copy) NSString *pushChannel;

/**
 * The userID
 */
@property(nonatomic, copy) NSString *userId;

/**
 * The expiration for the installation
 */
@property(nonatomic, copy) NSDate *expirationTime;

/**
 * A collection ofinstallation templates.
 */
@property(nonatomic, readonly, copy) NSDictionary<NSString *, ANHInstallationTemplate *> *templates;

/**
* Sets the template for the installation template for the given key.
*
* @param template The `MSInstallationTemplate` object containing the installation template data.
* @param key The key for the template.
*
* @returns YES if the template was added, else NO.
*
* @see MSInstallationTemplate
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
* Gets the installation template `MSInstallationTemplate` for the given key.
*
* @param key The key for the template.
*
* @returns The installation template instance
*
* @see MSInstallationTemplate
*/
- (ANHInstallationTemplate *)templateForKey:(NSString *)key;

/**
 * Converts the current installation into JSON Data.
 */
- (NSData *)toJSON;

@end
