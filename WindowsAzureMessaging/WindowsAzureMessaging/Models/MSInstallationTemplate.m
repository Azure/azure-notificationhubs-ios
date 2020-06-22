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
@synthesize isDirty;

- (instancetype)init {
    if ((self = [super init]) != nil) {
        tags = [NSSet new];
        headers = [NSDictionary new];
        [self addObserver:self forKeyPath:@"isDirty" options:0 context:NULL];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super init]) != nil) {
        body = [coder decodeObjectForKey:@"body"] ?: @"";
        tags = [coder decodeObjectForKey:@"tags"];
        headers = [coder decodeObjectForKey:@"headers"];
        isDirty = NO;
        [self addObserver:self forKeyPath:@"isDirty" options:0 context:NULL];
    }

    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"isDirty"];
}

#pragma mark Dirty Checks

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isDirty"]) {
        self.isDirty = YES;
    }
}

+ (NSSet *)keyPathsForValuesAffectingIsDirty {
    return [NSSet setWithObjects:NSStringFromSelector(@selector(body)), nil];
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
    self.isDirty = YES;

    self.tags = [tmpTags copy];
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
    
    if (hasTags && !self.isDirty) {
        self.isDirty = YES;
    }

    [tmpTags minusSet:[NSSet setWithArray:tagsToRemove]];

    self.tags = [tmpTags copy];
    return YES;
}

- (void)clearTags {
    if (self.tags.count == 0) {
        return;
    }
    
    if (!self.isDirty && self.tags.count > 0) {
        self.isDirty = YES;
    }
    self.tags = [NSSet new];
}

#pragma mark Headers

- (void)setHeaderValue:(NSString *)value forKey:(NSString *)key {
    NSMutableDictionary *tmpHeaders = [NSMutableDictionary dictionaryWithDictionary:self.headers];
    [tmpHeaders setObject:value forKey:key];
    self.isDirty = YES;
    self.headers = [tmpHeaders copy];
}

- (void)removeHeaderValueForKey:(NSString *)key {
    NSMutableDictionary *tmpHeaders = [NSMutableDictionary dictionaryWithDictionary:self.headers];
    if (!self.isDirty && [tmpHeaders objectForKey:key]) {
        self.isDirty = YES;
    }

    [tmpHeaders removeObjectForKey:key];
    self.headers = [tmpHeaders copy];
}

- (NSString *)getHeaderValueForKey:(NSString *)key {
    return [self.headers objectForKey:key];
}

#pragma mark Equality

- (NSUInteger)hash {
    return [self.body hash] ^ [self.headers hash] ^ [self.tags hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![(NSObject *)object isKindOfClass:[MSInstallationTemplate class]]) {
        return NO;
    }

    return [self isEqualToMSInstallationTemplate:(MSInstallationTemplate *)object];
}

- (BOOL)isEqualToMSInstallationTemplate:(MSInstallationTemplate *)template {
    BOOL isBodyEqual = ((!self.body && !template.body) || [self.body isEqualToString:template.body]);
    BOOL isTagsSetEqual = [self.tags isEqualToSet:template.tags];
    BOOL isHeadersDictionaryEqual = [self.headers isEqualToDictionary:template.headers];
    return isBodyEqual && isTagsSetEqual && isHeadersDictionaryEqual;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.body forKey:@"body"];
    [coder encodeObject:self.tags forKey:@"tags"];
    [coder encodeObject:self.headers forKey:@"headers"];
}

- (NSDictionary *)toDictionary {
    return @{
        @"body" : self.body,
        @"tags" : [self.tags allObjects],
        @"headers" : self.headers,
    };
}

@end
