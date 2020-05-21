//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@protocol MSTaggable

@property(nonatomic, copy, readonly) NSSet<NSString *> *tags;

- (BOOL)addTag:(NSString *)tag;
- (BOOL)addTags:(NSArray<NSString *> *)tagsToAdd;
- (BOOL)removeTag:(NSString *)tag;
- (BOOL)removeTags:(NSArray<NSString *> *)tagsToRemove;
- (void)clearTags;

@end
