//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

/**
 * Protocol for checking if the object has been modified.
 */
@protocol MSChangeTracking

/**
 * Determines whether the object is dirty or not.
 */
@property(nonatomic, assign) BOOL isDirty;

@end
