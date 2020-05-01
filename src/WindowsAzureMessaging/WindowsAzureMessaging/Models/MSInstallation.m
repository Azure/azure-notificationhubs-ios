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

- (NSData *) toJsonData {
    
    NSDictionary * dictionary = @{
       @"installationId" : self.installationID,
       @"platform" : self.platform,
       @"pushChannel" : self.pushChannel
    };
    
    return [NSJSONSerialization dataWithJSONObject:dictionary
    options:NSJSONWritingPrettyPrinted error:nil];
}

- (BOOL) updateWithJson:(NSString *)jsonString {
    NSData * data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:0
                                 error:&error];
    
    self.installationID = dictionary[@"installationId"];
    self.platform = dictionary[@"platform"];
    self.pushChannel = dictionary[@"pushChannel"];
    self.pushChannelExpired = dictionary[@"pushChannelExpired"];
    
    NSString * dateString = dictionary[@"expirationTime"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [formatter dateFromString:dateString];
    
    self.expirationTime = date;
    
    return true;
}

@end
