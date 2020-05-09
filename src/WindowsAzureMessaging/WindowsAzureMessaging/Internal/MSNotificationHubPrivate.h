//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MSNotificationHub.h"

@interface MSNotificationHub ()

- (NSString *)convertTokenToString:(NSData *)token;

@property(nonatomic) id<MSNotificationHubDelegate> delegate;

@end
