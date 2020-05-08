// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


#import "MSInstallationTemplate.h"

@implementation MSInstallationTemplate

- (NSUInteger) hash {
    NSUInteger result = 0;
    
    result += [self.body hash];
    result += [NSKeyedArchiver archivedDataWithRootObject:self.headers].hash;
    result += [NSKeyedArchiver archivedDataWithRootObject:self.tags].hash;
    
    return result;
}

- (instancetype) init {
    if(self = [super init]){
        self.tags = [NSMutableSet new];
        self.headers = [NSMutableDictionary new];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.body forKey:@"body"];
    [coder encodeObject:self.tags forKey:@"tags"];
    [coder encodeObject:self.headers forKey:@"headers"];
}

- (BOOL) isEqual:(id)object {
    if (self == object) {
      return YES;
    }
    
    return [self hash] == [object hash];
}

        
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.body = [coder decodeObjectForKey:@"body"] ?: @"";
        self.tags = [coder decodeObjectForKey:@"tags"];
        self.headers = [coder decodeObjectForKey:@"headers"];
    }
    
    return self;
}

@end
