//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSInstallation.h"

@implementation MSInstallation

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.installationID forKey:@"installationID"];
    [coder encodeObject:self.pushChannel forKey:@"pushChannel"];
    [coder encodeObject:self.tags forKey:@"tags"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.installationID = [coder decodeObjectForKey:@"installationID"] ?: [[NSUUID UUID] UUIDString];
        self.pushChannel = [coder decodeObjectForKey:@"pushChannel"];
        self.tags = [coder decodeObjectForKey:@"tags"];
    }

    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.installationID = [[NSUUID UUID] UUIDString];
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
    installation.pushChannel = dictionary[@"pushChannel"];
    installation.tags = dictionary[@"tags"];

    return installation;
}

- (NSData *)toJsonData {

    NSDictionary *dictionary = @{
        @"installationId" : self.installationID,
        @"platform" : @"apns",
        @"pushChannel" : self.pushChannel,
        @"tags" : [self.tags allObjects] ?: [NSArray new]
    };

    return [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
}

- (BOOL)addTags:(NSArray<NSString *> *)tags {
    NSMutableSet *tmpTags = [NSMutableSet setWithSet:self.tags];

    for (NSString *tag in tags) {
        if ([MSInstallation isValidTag:tag]) {
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
    return [self.installationID hash] ^ [self.pushChannel hash] ^ [self.tags hash];
}

- (BOOL)isEqualToMSInstallation:(MSInstallation *)installation {
    return [self.installationID isEqualToString:installation.installationID] &&
           [self.tags isEqualToSet:installation.tags];
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

+ (BOOL)isValidTag:(NSString *)tag {
    NSString *tagPattern = @"^[a-zA-Z0-9_@#\\.:\\-]{1,120}$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:tagPattern options:NSRegularExpressionCaseInsensitive
      error:nil];
    
    return [regex numberOfMatchesInString:tag options:0 range:NSMakeRange(0, tag.length)] > 0;
}

@end
