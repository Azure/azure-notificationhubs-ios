//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@protocol MSTaggable

/**
 * A collection of tags for the installation.
 */
@property(nonatomic, copy, readonly) NSSet<NSString *> *tags;

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
* @param tagsToAdd The tags array to add
*
* @returns YES if the tags were added, else NO.
*/
- (BOOL)addTags:(NSArray<NSString *> *)tagsToAdd;

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
* @param tagsToRemove The tags to remove.
*
* @returns YES if the tags were removed, else NO.
*/
- (BOOL)removeTags:(NSArray<NSString *> *)tagsToRemove;

/**
* Clears the tags from the current installation.
*/
- (void)clearTags;

@end
