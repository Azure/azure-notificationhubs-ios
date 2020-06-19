//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface MSNotificationHubAppDelegate : NSObject
/**
 * Enable/Disable Application forwarding.
 */
@property(atomic, getter=isEnabled) BOOL enabled;

@end
