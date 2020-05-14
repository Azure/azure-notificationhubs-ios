//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallationTemplate.h"

@implementation MSInstallationTemplate

@synthesize body;
@synthesize tags;
@synthesize headers;

- (NSUInteger) hash {
     return [self.body hash] ^ [self.headers hash] ^ [self.tags hash];
}

- (instancetype) init {
    if(self = [super init]){
        tags = [NSMutableSet new];
        headers = [NSMutableDictionary new];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:body forKey:@"body"];
    [coder encodeObject:tags forKey:@"tags"];
    [coder encodeObject:headers forKey:@"headers"];
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

- (BOOL)isEqualToMSInstallationTemplate:(MSInstallationTemplate *) template {
    return [body isEqualToString:template.body]
    && [tags isEqualToSet:template.tags]
    && [headers isEqualToDictionary:template.headers];
}
        
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        body = [coder decodeObjectForKey:@"body"] ?: @"";
        tags = [coder decodeObjectForKey:@"tags"];
        headers = [coder decodeObjectForKey:@"headers"];
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            body,@"body",
            [NSArray arrayWithArray:[tags allObjects]],@"tags",
            headers,@"headers",
            nil];
}

@end
