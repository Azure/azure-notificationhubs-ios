#import <Foundation/Foundation.h>
@class MSInstallation

@interface MSInstallationHelper : NSObject
+ (MSInstallation *) createInstallation: (NSString *) connectionString
+ (MSInstallation *) updateInstallation: (MSInstallation *) installation
@end
