//
//  MSInstallation.m
//  WindowsAzureMessaging
//
//  Created by User on 28.04.2020.
//  Copyright © 2020 Microsoft. All rights reserved.
//

#import "MSInstallation.h"

@interface MSInstallation ()

@property(nonatomic, copy) NSString *installationID;

@end

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

@end
