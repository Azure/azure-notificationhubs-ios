//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "SBURLSession.h"
#import "SBStaticHandlerResponse.h"

typedef SBStaticHandlerResponse * (^StaticHandleBlock)(NSURLRequest *);

@interface SBURLSession()

+ (void)setStaticHandler:(StaticHandleBlock)staticHandler;

@end
