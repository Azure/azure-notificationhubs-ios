//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "SBRegistration.h"

@interface SBRegistrationParser : NSObject {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-interface-ivars"
  @private
    NSMutableArray *_allRegistrations;
    NSMutableString *_currentElementValue;
    SBRegistration *_currentRegistration;
}

#pragma GCC diagnostic pop

- (SBRegistrationParser *)initParserWithResult:(NSMutableArray *)result;

+ (NSArray *)parseRegistrations:(NSData *)data error:(NSError **)error;
@end
