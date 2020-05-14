//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSNotificationHub.h"
#import <Foundation/Foundation.h>

@interface MSNotificationHub ()

- (NSString *)convertTokenToString:(NSData *)token;

@property(nonatomic) id<MSNotificationHubDelegate> delegate;

@end
