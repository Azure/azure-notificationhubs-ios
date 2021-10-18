//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHInstallationTemplate.h"
#import "ANHInstallationTemplate+Private.h"
#import "ANHTagHelper.h"

@implementation ANHInstallationTemplate

@synthesize body;
@synthesize tags;
@synthesize headers;

- (instancetype)init {
    if ((self = [super init]) != nil) {
        tags = [NSSet new];
        headers = [NSDictionary new];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super init]) != nil) {
        body = [coder decodeObjectForKey:@"body"] ?: @"";
        tags = [coder decodeObjectForKey:@"tags"];
        headers = [coder decodeObjectForKey:@"headers"];
    }

    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"isDirty"];
}

#pragma mark Tags

- (BOOL)addTag:(NSString *)tag {
    return [self addTags:[NSArray arrayWithObject:tag]];
}

- (BOOL)addTags:(NSArray<NSString *> *)tagsToAdd {
    NSArray *invalidTags = [tagsToAdd filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, __unused NSDictionary *bindings) {
        return !isValidTag(evaluatedObject);
    }]];
                             
     if (invalidTags.count > 0) {
         return NO;
     }
    
    NSMutableSet *tmpTags = [NSMutableSet setWithSet:self.tags];
    [tmpTags addObjectsFromArray:tagsToAdd];

    tags = [tmpTags copy];
    return YES;
}

- (BOOL)removeTag:(NSString *)tag {
    return [self removeTags:[NSArray arrayWithObject:tag]];
}

- (BOOL)removeTags:(NSArray<NSString *> *)tagsToRemove {
    NSMutableSet *tmpTags = [NSMutableSet setWithSet:self.tags];

    BOOL hasTags = [[NSSet setWithArray:tagsToRemove] intersectsSet:tmpTags];
    
    if (!hasTags) {
        return NO;
    }

    [tmpTags minusSet:[NSSet setWithArray:tagsToRemove]];

    tags = [tmpTags copy];
    return YES;
}

- (void)clearTags {
    if (tags.count == 0) {
        return;
    }
    
    tags = [NSSet new];
}

#pragma mark Headers

- (void)setHeader:(NSString *)value forKey:(NSString *)key {
    NSMutableDictionary *tmpHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
    [tmpHeaders setObject:value forKey:key];
    headers = [tmpHeaders copy];
}

- (void)removeHeaderForKey:(NSString *)key {
    NSMutableDictionary *tmpHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
    [tmpHeaders removeObjectForKey:key];
    headers = [tmpHeaders copy];
}

- (NSString *)headerForKey:(NSString *)key {
    return [headers objectForKey:key];
}

#pragma mark Equality

- (NSUInteger)hash {
    return [self.body hash] ^ [self.headers hash] ^ [self.tags hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![(NSObject *)object isKindOfClass:[ANHInstallationTemplate class]]) {
        return NO;
    }

    return [self isEqualToANHInstallationTemplate:(ANHInstallationTemplate *)object];
}

- (BOOL)isEqualToANHInstallationTemplate:(ANHInstallationTemplate *)template {
    // We have to check for nil values
    BOOL isBodyEqual = body == template.body || [body isEqualToString:template.body];
    BOOL isTagsSetEqual = [tags isEqualToSet:template.tags];
    BOOL isHeadersDictionaryEqual = [headers isEqualToDictionary:template.headers];
    return isBodyEqual && isTagsSetEqual && isHeadersDictionaryEqual;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:body forKey:@"body"];
    [coder encodeObject:tags forKey:@"tags"];
    [coder encodeObject:headers forKey:@"headers"];
}

- (NSDictionary *)toDictionary {
    return @{
        @"body" : body,
        @"tags" : [tags allObjects],
        @"headers" : headers,
    };
}

@end
