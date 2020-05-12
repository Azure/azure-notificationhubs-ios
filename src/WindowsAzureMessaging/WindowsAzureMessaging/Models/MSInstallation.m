//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallation.h"
#import "MSInstallationTemplate.h"

@implementation MSInstallation

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.installationID forKey:@"installationID"];
    [coder encodeObject:self.pushChannel forKey:@"pushChannel"];
    [coder encodeObject:self.platform forKey:@"platform"];
    [coder encodeObject:self.tags forKey:@"tags"];
    [coder encodeObject:self.templates forKey:@"templates"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.installationID = [coder decodeObjectForKey:@"installationID"] ?: [[NSUUID UUID] UUIDString];
        self.pushChannel = [coder decodeObjectForKey:@"pushChannel"];
        self.platform = [coder decodeObjectForKey:@"platform"] ?: @"APNS";
        self.tags = [coder decodeObjectForKey:@"tags"];
        self.templates = [coder decodeObjectForKey:@"templates"];
    }

    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.installationID = [[NSUUID UUID] UUIDString];
        self.platform = @"APNS";
        self.tags = [NSSet new];
    }

    return self;
}

- (instancetype)initWithDeviceToken:(NSString *)deviceToken {
    if (self = [self init]) {
        self.pushChannel = deviceToken;
    }

    return self;
}

+ (MSInstallation *)createFromDeviceToken:(NSString *)deviceToken {
    return [[MSInstallation alloc] initWithDeviceToken:deviceToken];
}

+ (MSInstallation *)createFromJsonString:(NSString *)jsonString {
    MSInstallation *installation = [MSInstallation new];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    installation.installationID = dictionary[@"installationId"];
    installation.platform = dictionary[@"platform"];
    installation.pushChannel = dictionary[@"pushChannel"];
    installation.tags = dictionary[@"tags"];
    installation.templates = dictionary[@"templates"];

    return installation;
}

- (NSData *)toJsonData {
    NSMutableDictionary *templates = [NSMutableDictionary new];
    for(NSString *key in [self.templates allKeys]){
        [templates setObject:[[self.templates objectForKey:key] toDictionary] forKey:key];
    };
    
    NSDictionary *dictionary = @{
        @"installationId" : self.installationID,
        @"platform" : self.platform,
        @"pushChannel" : self.pushChannel,
        @"tags" : [NSArray arrayWithArray:[self.tags allObjects]],
        @"templates": templates ?: [NSDictionary new]
    };
    
    return [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
}

- (BOOL)addTags:(NSArray<NSString *> *)tags {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9_@#\\.:\\-]{1,120}$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSMutableSet *tmpTags = [NSMutableSet setWithSet:self.tags];

    for (NSString *tag in tags) {
        if ([regex numberOfMatchesInString:tag options:0 range:NSMakeRange(0, tag.length)] > 0) {
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

- (BOOL)removeTags:(NSArray<NSString *> *)tags {
    NSMutableSet *tmpTags = [NSMutableSet setWithSet:self.tags];

    [tmpTags minusSet:[NSSet setWithArray:tags]];

    self.tags = [tmpTags copy];
    return YES;
}

- (void)clearTags {
    self.tags = [NSSet new];
}

- (NSUInteger)hash {
    return [self.installationID hash] ^ [self.platform hash] ^ [self.pushChannel hash] ^ [self.tags hash] ^ [self.templates hash];
}

- (BOOL) addTemplate:(MSInstallationTemplate *) template forKey:(NSString *) templateKey {
    NSMutableDictionary<NSString *, MSInstallationTemplate *> *tmpTemplates = [NSMutableDictionary dictionaryWithDictionary:self.templates];
    
    if ([[tmpTemplates allKeysForObject:template] count] > 0) {
        return NO;
    }
    
    [tmpTemplates setObject:template forKey:templateKey];
    self.templates = tmpTemplates;
    return YES;
}

- (BOOL) removeTemplate:(NSString *)templateKey {
    NSMutableDictionary<NSString *, MSInstallationTemplate *> *tmpTemplates = [NSMutableDictionary dictionaryWithDictionary:self.templates];
    
    if (![tmpTemplates objectForKey:templateKey]) {
        return NO;
    }
    
    [tmpTemplates removeObjectForKey:templateKey];
    self.templates = tmpTemplates;
    return YES;
}

- (MSInstallationTemplate *) getTemplate:(NSString *)templateKey {
    return [self.templates objectForKey:templateKey];
}

- (BOOL)isEqualToMSInstallation:(MSInstallation *)installation {
    return [self.installationID isEqualToString:installation.installationID] && [self.platform isEqualToString:installation.platform] &&
    [self.tags isEqualToSet:installation.tags] && [self.templates isEqual:installation.templates];
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
