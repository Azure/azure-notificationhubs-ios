// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

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

- (instancetype) init {
    if(self = [super init]) {
        self.installationID = [[NSUUID UUID] UUIDString];
        self.platform = @"APNS";
    }
    
    return self;
}

- (instancetype) initWithDeviceToken:(NSString *) deviceToken {
    if (self = [self init]) {
        self.pushChannel = deviceToken;
    }
    
    return self;
}

+ (MSInstallation *) createFromDeviceToken:(NSString *) deviceToken {
    return [[MSInstallation alloc] initWithDeviceToken:deviceToken];
}

+ (MSInstallation *) createFromJsonString:(NSString *)jsonString {
    MSInstallation *installation = [MSInstallation new];
    NSData * data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:0
                                 error:&error];
    
    installation.installationID = dictionary[@"installationId"];
    installation.platform = dictionary[@"platform"];
    installation.pushChannel = dictionary[@"pushChannel"];
    installation.tags = dictionary[@"tags"];
    installation.templates = dictionary[@"templates"];
    
    return installation;
}

- (NSData *) toJsonData {
    
    NSDictionary * dictionary = @{
       @"installationId" : self.installationID,
       @"platform" : self.platform,
       @"pushChannel" : self.pushChannel,
       @"tags" : self.tags ?: @"",
       @"templates": self.templates ?: @""
    };
    
    return [NSJSONSerialization dataWithJSONObject:dictionary
    options:NSJSONWritingPrettyPrinted error:nil];
}

- (BOOL) addTags:(NSArray<NSString *> *)tags {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9_@#\\.:\\-]{1,120}$"
    options:NSRegularExpressionCaseInsensitive error:nil];
    NSMutableArray *tmpTags = [NSMutableArray arrayWithArray:self.tags];
    
    for(NSString *tag in tags) {
        if(![tmpTags containsObject:tag]) {
            if([regex numberOfMatchesInString:tag options:0 range:NSMakeRange(0, tag.length)] > 0) {
                [tmpTags addObject:tag];
            } else {
                NSLog(@"Invalid tag: %@", tag);
                return NO;
            }
            
        }
    }
    
    self.tags = tmpTags;
    return YES;
}

- (NSArray<NSString *> *) getTags {
    return self.tags;
}

- (BOOL) removeTags:(NSArray<NSString *> *)tags {
    NSMutableArray *tmpTags = [NSMutableArray arrayWithArray:self.tags];
    
    [tmpTags removeObjectsInArray:tags];
    
    self.tags = tmpTags;
    return YES;
}

- (void) clearTags {
    self.tags = [NSArray new];
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

- (NSUInteger) hash {
    NSUInteger result = 0;
    
    result += [self.installationID hash];
    result += [self.platform hash];
    result += [self.pushChannel hash];
    result += [self.tags hash];
    result += [self.templates hash];
    
    return result;
}

- (BOOL) isEqual:(id)object {
    if (self == object) {
      return YES;
    }
    
    return [self hash] == [object hash];
}

@end
