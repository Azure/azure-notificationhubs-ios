//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef ANH_CUSTOM_DELEGATE_h
#define ANH_CUSTOM_DELEGATE_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Custom delegate.
 *
 * @discussion Delegates here are using swizzling. Any delegate that can be registered through the notification center should not be
 * registered through swizzling. Due to the early registration of swizzling on the original app delegate each custom delegate must sign up
 * for selectors to swizzle within the `load` method of a category over the @see ANHDelegateForwarder class.
 */
@protocol ANHCustomDelegate <NSObject>

@end

NS_ASSUME_NONNULL_END

#endif
