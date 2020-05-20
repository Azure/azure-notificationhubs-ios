//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallationTemplate.h"
#import "MSTagHelper.h"

@interface MSInstallationTemplate ()

@property(nonatomic, copy) NSSet<NSString *> *tags;
@property(nonatomic, copy) NSDictionary<NSString *, NSString *> *headers;

@end

@implementation MSInstallationTemplate

@synthesize body;
@synthesize tags;
@synthesize headers;

- (instancetype)init {
    if (self = [super init]) {
        tags = [NSSet new];
        headers = [NSDictionary new];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        body = [coder decodeObjectForKey:@"body"] ?: @"";
        tags = [coder decodeObjectForKey:@"tags"];
        headers = [coder decodeObjectForKey:@"headers"];
    }

    return self;
}

#pragma mark Tags

- (BOOL)addTag:(NSString *)tag {
    return [self addTags:[NSArray arrayWithObject:tag]];
}

- (BOOL)addTags:(NSArray<NSString *> *)tagsToAdd {
    NSMutableSet *tmpTags = [NSMutableSet setWithSet:self.tags];

    for (NSString *tag in tagsToAdd) {
        if (isValidTag(tag)) {
            [tmpTags addObject:tag];
        } else {
            NSLog(@"Invalid tag: %@", tag);
            return NO;
        }
    }

    self.tags = [tmpTags copy];
    return YES;
}

- (NSArray<NSString *> *)getTags {
    return [[self.tags copy] allObjects];
}

- (BOOL)removeTag:(NSString *)tag {
    return [self removeTags:[NSArray arrayWithObject:tag]];
}

- (BOOL)removeTags:(NSArray<NSString *> *)tagsToRemove {
    NSMutableSet *tmpTags = [NSMutableSet setWithSet:self.tags];

    [tmpTags minusSet:[NSSet setWithArray:tagsToRemove]];

    self.tags = [tmpTags copy];
    return YES;
}

- (void)clearTags {
    self.tags = [NSSet new];
}

#pragma mark Headers

- (void)setHeader:(NSString *)value forKey:(NSString *)key {
    NSMutableDictionary *tmpHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
    [tmpHeaders setObject:value forKey:key];
    headers = [tmpHeaders copy];
}

- (void)removeHeader:(NSString *)key {
       NSMutableDictionary *tmpHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
    [tmpHeaders removeObjectForKey:key];
    headers = [tmpHeaders copy];
}

- (NSString *)getHeader:(NSString *)key {
    return [headers objectForKey:key];
}

- (NSDictionary<NSString *, NSString *> *)getHeaders {
    return [headers copy];
}

#pragma mark Equality

- (NSUInteger)hash {
    return [self.body hash] ^ [self.headers hash] ^ [self.tags hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[MSInstallationTemplate class]]) {
        return NO;
    }

    return [self isEqualToMSInstallationTemplate:(MSInstallationTemplate *)object];
}

- (BOOL)isEqualToMSInstallationTemplate:(MSInstallationTemplate *)template {
    return [body isEqualToString:template.body] && [tags isEqualToSet:template.tags] && [headers isEqualToDictionary:template.headers];
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:body forKey:@"body"];
    [coder encodeObject:tags forKey:@"tags"];
    [coder encodeObject:headers forKey:@"headers"];
}

- (NSDictionary *)toDictionary {
    return [NSDictionary
        dictionaryWithObjectsAndKeys:body, @"body", [NSArray arrayWithArray:[tags allObjects]], @"tags", headers, @"headers", nil];
}

@end
