#import <Foundation/Foundation.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^InstallationCompletionHandler)(NSError *_Nullable);
typedef void (^InstallationGetCompletionHandler)(MSInstallation *_Nullable, NSError *_Nullable);

@interface CustomInstallationManager : NSObject

- (instancetype)initWithConnectionString:(NSString *)connectionString hubName:(NSString *)hubName;

- (void)getInstallation:(NSString *)installationId completionHandler:(InstallationGetCompletionHandler)completionHandler;

- (void)saveInstallation:(MSInstallation *)installation completionHandler:(InstallationCompletionHandler)completionHandler;

- (void)patchInstallation:(NSArray *)patchOperations forInstallationId:(NSString *)installationId completionHandler:(InstallationCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
