// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


#import "MSInstallationTemplate.h"

@implementation MSInstallationTemplate

- (NSUInteger) hash {
    NSUInteger result = 0;
    
    result += [self.body hash];
    result += [self.headers hash];
    result += [self.tags hash];
    
    return result;
}

- (BOOL) isEqual:(id)object {
    if (self == object) {
      return YES;
    }
    
    return [self hash] == [object hash];
}

@end
