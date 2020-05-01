//
//  MSInstallation.m
//  WindowsAzureMessaging
//
//  Created by User on 28.04.2020.
//  Copyright © 2020 Microsoft. All rights reserved.
//

#import "MSInstallation.h"

@implementation MSInstallation

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.installationID forKey:@"installationID"];
    [coder encodeObject:self.pushChannel forKey:@"pushChannel"];
    [coder encodeObject:self.platform forKey:@"platform"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.installationID = [coder decodeObjectForKey:@"installationID"];
        self.pushChannel = [coder decodeObjectForKey:@"pushChannel"];
        self.platform = [coder decodeObjectForKey:@"platform"];
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
    installation.pushChannelExpired = (BOOL)dictionary[@"pushChannelExpired"];
    
    NSString * dateString = dictionary[@"expirationTime"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [formatter dateFromString:dateString];
    
    installation.expirationTime = date;
    
    return installation;
}

- (NSData *) toJsonData {
    
    NSDictionary * dictionary = @{
       @"installationId" : self.installationID,
       @"platform" : self.platform,
       @"pushChannel" : self.pushChannel
    };
    
    return [NSJSONSerialization dataWithJSONObject:dictionary
    options:NSJSONWritingPrettyPrinted error:nil];
}

@end
