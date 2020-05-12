// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


#import "MSInstallationTemplate.h"

@implementation MSInstallationTemplate

- (NSUInteger) hash {
     return [self.body hash] ^ [self.headers hash] ^ [self.tags hash];
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
    
    if (![object isKindOfClass:[MSInstallationTemplate class]]) {
        return NO;
    }
    
    return [self isEqualToMSInstallationTemplate:(MSInstallationTemplate *)object];
}

- (BOOL)isEqualToMSInstallationTemplate:(MSInstallationTemplate *)template {
    return [self.body isEqualToString:template.body]
    && [self.tags isEqualToSet:template.tags]
    && [self.headers isEqualToDictionary:template.headers];
}
        
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.body = [coder decodeObjectForKey:@"body"] ?: @"";
        self.tags = [coder decodeObjectForKey:@"tags"];
        self.headers = [coder decodeObjectForKey:@"headers"];
    }
    
    return self;
}

- (NSDictionary *) toDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            self.body,@"body",
            [NSArray arrayWithArray:[self.tags allObjects]],@"tags",
            self.headers,@"headers",
            nil];
}

@end
