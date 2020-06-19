//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#ifndef MSApplication_h
#define MSApplication_h

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>

#ifndef MSApplicationDelegate
#define MSApplicationDelegate NSApplicationDelegate
#endif

#ifndef MSApplication
#define MSApplication NSApplication
#endif
#else
#import <UIKit/UIKit.h>

#ifndef MSApplicationDelegate
#define MSApplicationDelegate UIApplicationDelegate
#endif

#ifndef MSApplication
#define MSApplication UIApplication
#endif

#endif

#endif /* MSApplication_h */
