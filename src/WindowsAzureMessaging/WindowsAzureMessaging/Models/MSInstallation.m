//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallation.h"
#import "MSInstallationTemplate.h"
#import "MSTagHelper.h"

@interface MSInstallation ()

@property(nonatomic, copy) NSDictionary<NSString *, MSInstallationTemplate *> *templates;
@property(nonatomic, copy) NSSet<NSString *> *tags;

@end

@implementation MSInstallation

NSString * const kInstallationId = @"installationId";
NSString * const kPushChannel = @"pushChannel";
NSString * const kExpiration = @"expiration";
NSString * const kTags = @"tags";
NSString * const kTemplates = @"templates";
NSString * const kIsDirty = @"isDirty";

@synthesize isDirty;
@synthesize installationId;
@synthesize expiration;
@synthesize pushChannel;
@synthesize tags;
@synthesize templates;

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:installationId forKey:kInstallationId];
    [coder encodeObject:pushChannel forKey:kPushChannel];
    [coder encodeObject:expiration forKey:kExpiration];
    [coder encodeObject:tags forKey:kTags];
    [coder encodeObject:templates forKey:kTemplates];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        installationId = [coder decodeObjectForKey:kInstallationId] ?: [[NSUUID UUID] UUIDString];
        pushChannel = [coder decodeObjectForKey:kPushChannel];
        expiration = [coder decodeObjectForKey:kExpiration];
        tags = [coder decodeObjectForKey:kTags];
        templates = [coder decodeObjectForKey:kTemplates];
        isDirty = NO;
        [self addObserver:self forKeyPath:kIsDirty options:0 context:NULL];
    }

    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        installationId = [[NSUUID UUID] UUIDString];
        tags = [NSSet new];
        isDirty = NO;
        [self addObserver:self forKeyPath:kIsDirty options:0 context:NULL];
    }

    return self;
}

- (instancetype)initWithDeviceToken:(NSString *)deviceToken {
    if (self = [self init]) {
        pushChannel = deviceToken;
    }

    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:kIsDirty];
}

+ (instancetype)createFromDeviceToken:(NSString *)deviceToken {
    return [[MSInstallation alloc] initWithDeviceToken:deviceToken];
}

+ (instancetype)createFromJsonString:(NSString *)jsonString {
    MSInstallation *installation = [MSInstallation new];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    installation.installationId = dictionary[kInstallationId];
    installation.pushChannel = dictionary[kPushChannel];
    installation.expiration = dictionary[kExpiration];
    installation.tags = dictionary[kTags];
    installation.templates = dictionary[kTemplates];
    installation.isDirty = NO;

    return installation;
}

- (NSData *)toJsonData {
    NSMutableDictionary *templates = [NSMutableDictionary new];
    for (NSString *key in [templates allKeys]) {
        [templates setObject:[[templates objectForKey:key] toDictionary] forKey:key];
    };

    NSMutableDictionary *dictionary = [NSMutableDictionary
        dictionaryWithDictionary:@{kInstallationId : self.installationId, @"platform" : @"apns", kPushChannel : self.pushChannel}];

    if (tags && [tags count] > 0) {
        [dictionary setObject:[NSArray arrayWithArray:[self.tags allObjects]] forKey:kTags];
    }

    if (templates && [templates count] > 0) {
        [dictionary setObject:templates forKey:kTemplates];
    }

    return [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
}

#pragma mark Dirty Checks

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kIsDirty]) {
        isDirty = YES;
    }
}

+ (NSSet *)keyPathsForValuesAffectingIsDirty {
    return [NSSet setWithObjects:NSStringFromSelector(@selector(installationId)), NSStringFromSelector(@selector(pushChannel)), nil];
}

#pragma mark Tags

- (BOOL)addTag:(NSString *)tag {
    return [self addTags:[NSArray arrayWithObject:tag]];
}

- (BOOL)addTags:(NSArray<NSString *> *)tagsToAdd {
    NSArray *invalidTags = [tagsToAdd filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return !isValidTag(evaluatedObject);
    }]];
                             
     if (invalidTags.count > 0) {
         return NO;
     }
    
    NSMutableSet *tmpTags = [NSMutableSet setWithSet:tags];
    [tmpTags addObjectsFromArray:tagsToAdd];
    isDirty = YES;

    tags = [tmpTags copy];
    return YES;
}

- (BOOL)removeTag:(NSString *)tag {
    return [self removeTags:[NSArray arrayWithObject:tag]];
}

- (BOOL)removeTags:(NSArray<NSString *> *)tagsToRemove {
    NSMutableSet *tmpTags = [NSMutableSet setWithSet:tags];

    BOOL hasTags = [[NSSet setWithArray:tagsToRemove] intersectsSet:tmpTags];
    if (!hasTags) {
        return NO;
    }
    
    if (hasTags && !isDirty) {
        isDirty = YES;
    }

    [tmpTags minusSet:[NSSet setWithArray:tagsToRemove]];

    tags = [tmpTags copy];
    return YES;
}

- (void)clearTags {
    if (tags.count == 0) {
        return;
    }
    
    if (!isDirty && tags.count > 0) {
        isDirty = YES;
    }
    tags = [NSSet new];
}

#pragma mark Templates

- (BOOL)setTemplate:(MSInstallationTemplate *)template forKey:(NSString *)templateKey {
    NSMutableDictionary<NSString *, MSInstallationTemplate *> *tmpTemplates = [NSMutableDictionary dictionaryWithDictionary:self.templates];

    [tmpTemplates setObject:template forKey:templateKey];
    self.templates = tmpTemplates;
    self.isDirty = YES;
    return YES;
}

- (BOOL)removeTemplateForKey:(NSString *)templateKey {
    NSMutableDictionary<NSString *, MSInstallationTemplate *> *tmpTemplates = [NSMutableDictionary dictionaryWithDictionary:self.templates];

    if (![tmpTemplates objectForKey:templateKey]) {
        return NO;
    }

    [tmpTemplates removeObjectForKey:templateKey];
    self.templates = tmpTemplates;
    self.isDirty = YES;
    return YES;
}

- (MSInstallationTemplate *)getTemplateForKey:(NSString *)templateKey {
    return [self.templates objectForKey:templateKey];
}

#pragma mark Equality

- (NSUInteger)hash {
    return [installationId hash] ^ [expiration hash] ^ [pushChannel hash] ^ [tags hash] ^ [templates hash];
}

- (BOOL)isEqualToMSInstallation:(MSInstallation *)installation {
    BOOL isInstallationsIdEqual = [installationId isEqualToString:installation.installationId];
    BOOL isExpirationEqual = [expiration isEqualToDate:installation.expiration];
    BOOL isTagsSetEqual = [tags isEqualToSet:installation.tags];
    // We have to check for nil values
    BOOL isTemplatesDictionaryEqual =
        templates == installation.templates ?: [templates isEqualToDictionary:installation.templates];
    return isInstallationsIdEqual && isExpirationEqual && isTagsSetEqual && isTemplatesDictionaryEqual;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[MSInstallation class]]) {
        return NO;
    }

    return [self isEqualToMSInstallation:(MSInstallation *)object];
}

@end
