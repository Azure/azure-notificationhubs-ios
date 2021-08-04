//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

#if __has_attribute(swift_async)
// Switch to NS_SWIFT_DISABLE_ASYNC once Xcode 13 is available
#define ANH_SWIFT_DISABLE_ASYNC __attribute__((swift_async(none)))
#else
#define ANH_SWIFT_DISABLE_ASYNC
#endif
