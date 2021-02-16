//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHTagHelper.h"
#import <Foundation/Foundation.h>

BOOL isValidTag(NSString *tag) {
    NSString *tagPattern = @"^[a-zA-Z0-9_@#\\.:\\-]{1,120}$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:tagPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];

    return [regex numberOfMatchesInString:tag options:0 range:NSMakeRange(0, tag.length)] > 0;
}
