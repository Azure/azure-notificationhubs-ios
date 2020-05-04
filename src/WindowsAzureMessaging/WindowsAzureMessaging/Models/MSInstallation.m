// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#import "MSInstallation.h"

@implementation MSInstallation

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.installationID forKey:@"installationID"];
    [coder encodeObject:self.pushChannel forKey:@"pushChannel"];
    [coder encodeObject:self.platform forKey:@"platform"];
    [coder encodeObject:self.tags forKey:@"tags"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.installationID = [coder decodeObjectForKey:@"installationID"] ?: [[NSUUID UUID] UUIDString];
        self.pushChannel = [coder decodeObjectForKey:@"pushChannel"];
        self.platform = [coder decodeObjectForKey:@"platform"] ?: @"APNS";
        self.tags = [coder decodeObjectForKey:@"tags"];
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
    
    return installation;
}

- (NSData *) toJsonData {
    
    NSDictionary * dictionary = @{
       @"installationId" : self.installationID,
       @"platform" : self.platform,
       @"pushChannel" : self.pushChannel,
       @"tags" : self.tags ?: @""
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
            if([regex numberOfMatchesInString:tag options:0 range:NSMakeRange(0, tag.length)] > 0)
            {
                [tmpTags addObject:tag];
            } else {
                NSLog(@"Invalid tag: %@", tag);
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

@end
