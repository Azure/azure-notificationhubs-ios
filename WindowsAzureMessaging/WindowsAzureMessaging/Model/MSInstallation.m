//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallation.h"
#import "MSInstallation+Private.h"
#import "MSInstallationTemplate.h"
#import "MSTagHelper.h"

@implementation MSInstallation

@synthesize isDirty;
@synthesize installationId;
@synthesize expirationTime;
@synthesize pushChannel;
@synthesize tags;
@synthesize userId;
@synthesize templates;

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:installationId forKey:@"installationId"];
    [coder encodeObject:expirationTime forKey:@"expirationTime"];
    [coder encodeObject:pushChannel forKey:@"pushChannel"];
    [coder encodeObject:tags forKey:@"tags"];
    [coder encodeObject:userId forKey:@"userId"];
    [coder encodeObject:templates forKey:@"templates"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if ((self = [super init]) != nil) {
        installationId = [coder decodeObjectForKey:@"installationId"] ?: [[NSUUID UUID] UUIDString];
        expirationTime = [coder decodeObjectForKey:@"expirationTime"];
        pushChannel = [coder decodeObjectForKey:@"pushChannel"];
        tags = [coder decodeObjectForKey:@"tags"];
        userId = [coder decodeObjectForKey:@"userId"];
        templates = [coder decodeObjectForKey:@"templates"];
        isDirty = NO;
        [self addObserver:self forKeyPath:@"isDirty" options:0 context:NULL];
    }

    return self;
}

- (instancetype)init {
    if ((self = [super init]) != nil) {
        installationId = [[NSUUID UUID] UUIDString];
        isDirty = NO;
        [self addObserver:self forKeyPath:@"isDirty" options:0 context:NULL];
    }

    return self;
}

- (instancetype)initWithDeviceToken:(NSString *)deviceToken {
    if ((self = [self init]) != nil) {
        pushChannel = deviceToken;
    }

    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"isDirty"];
}

+ (instancetype)createFromDeviceToken:(NSString *)deviceToken {
    return [[MSInstallation alloc] initWithDeviceToken:deviceToken];
}

+ (instancetype)createFromJSON:(NSDictionary *)json {
    MSInstallation *installation = [MSInstallation new];

    installation.installationId = json[@"installationId"];
    installation.pushChannel = json[@"pushChannel"];
    installation.tags = json[@"tags"];
    installation.userId = json[@"userId"];
    installation.templates = json[@"templates"];
    
    NSString *expiration = json[@"expirationTime"];
    if (expiration) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mmZ"];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        
        installation.expirationTime = [dateFormatter dateFromString:expiration];
    }
    
    installation.isDirty = NO;

    return installation;
}

- (NSData *)toJsonData {
    NSMutableDictionary *resultTemplates = [NSMutableDictionary new];
    for (NSString *key in [templates allKeys]) {
        MSInstallationTemplate *template = [templates objectForKey:key];
        [resultTemplates setObject:[template toDictionary] forKey:key];
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary
        dictionaryWithDictionary:@{@"installationId" : self.installationId, @"platform" : @"apns", @"pushChannel" : self.pushChannel}];
    
    if (expirationTime) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mmZ"];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        
        [dictionary setObject:[dateFormatter stringFromDate:expirationTime] forKey:@"expirationTime"];
    }

    if (tags && [tags count] > 0) {
        [dictionary setObject:[NSArray arrayWithArray:[self.tags allObjects]] forKey:@"tags"];
    }
    
    if (userId && [userId length] > 0) {
        [dictionary setObject:userId forKey:@"userId"];
    }

    if (templates && [templates count] > 0) {
        [dictionary setObject:templates forKey:@"templates"];
    }

    return [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
}

#pragma mark Dirty Checks

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isDirty"]) {
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
    NSArray *invalidTags = [tagsToAdd filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, __unused NSDictionary *bindings) {
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
    return [self.installationId hash] ^ [self.pushChannel hash] ^ [self.tags hash] ^ [self.templates hash] ^ [self.expirationTime hash];
}

- (BOOL)isEqualToMSInstallation:(MSInstallation *)installation {
    BOOL isInstallationsIdEqual = [self.installationId isEqualToString:installation.installationId];
    BOOL isExpirationTimeEqual = ((!self.expirationTime && !installation.expirationTime) || [[NSCalendar currentCalendar] isDate:self.expirationTime equalToDate:installation.expirationTime toUnitGranularity:NSCalendarUnitDay]);
    BOOL isTagsSetEqual = ((!self.tags && !installation.tags) || [self.tags isEqualToSet:installation.tags]);
    BOOL isUserIdEqual = ((!self.userId && !installation.userId) || [self.userId isEqualToString:installation.userId]);
    BOOL isTemplatesDictionaryEqual = ((!self.templates && !installation.templates) || [self.templates isEqualToDictionary:installation.templates]);
    return isInstallationsIdEqual && isExpirationTimeEqual && isTagsSetEqual && isUserIdEqual && isTemplatesDictionaryEqual;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![(NSObject *)object isKindOfClass:[MSInstallation class]]) {
        return NO;
    }

    return [self isEqualToMSInstallation:(MSInstallation *)object];
}

@end
