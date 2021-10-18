//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHLocalStorage.h"
#import "ANHLogger.h"
#import "ANH_Errors.h"

@implementation ANHLocalStorage

+ (id)objectForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    
    if (!encodedObject) {
        return nil;
    }
    
    NSError *error;
    NSObject *unarchivedData;
    NSException *exception;
    
    @try {
        if (@available(iOS 11.0, macOS 10.13, watchOS 4.0, *)) {
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:encodedObject error:&error];
            unarchiver.requiresSecureCoding = NO;
            unarchivedData = [unarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:&error];
        } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
#pragma GCC diagnostic pop
        }
    } @catch (NSException *ex) {
        exception = ex;
    }
    
    if (!unarchivedData || exception) {
        ANHLogError(kANHLogDomain, @"Unarchiving NSData failed with error: %@",
              exception ? exception.reason : error.localizedDescription);
        return nil;
    }
    
    return unarchivedData;
}

+ (id)setObject:(id)data forKey:(NSString *)key {
    if (!data) {
        return nil;
    }
    
    NSError *error;
    NSData *archivedData;
    NSException *exception;
    
    @try {
        if (@available(iOS 11.0, macOS 10.13, watchOS 4.0, *)) {
            archivedData = [NSKeyedArchiver archivedDataWithRootObject:data requiringSecureCoding:NO error:&error];
        } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            archivedData = [NSKeyedArchiver archivedDataWithRootObject:data];
#pragma GCC diagnostic pop
        }
    } @catch (NSException *ex) {
        exception = ex;
    }
    
    if (!archivedData || exception) {
        ANHLogError(kANHLogDomain, @"Archiving NSData failed with error: %@",
              exception ? exception.reason : error.localizedDescription);
        return nil;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:archivedData forKey:key];
    
    return data;
}

+ (void)clearForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:key];
}

@end
