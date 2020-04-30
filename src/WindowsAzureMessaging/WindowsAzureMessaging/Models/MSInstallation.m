//
//  MSInstallation.m
//  WindowsAzureMessaging
//
//  Created by User on 28.04.2020.
//  Copyright © 2020 Microsoft. All rights reserved.
//

#import "MSInstallation.h"

@implementation MSInstallation

- (void)encodeWithCoder:(nonnull NSCoder *)encoder {
    [encoder encodeObject:self.installationID forKey:@"installationID"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder {
    if (self = [super init]) {
        self.installationID = [decoder decodeObjectForKey:@"installationID"];
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
