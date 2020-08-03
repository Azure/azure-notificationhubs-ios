//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "SBNotificationHubHelper.h"
#import "SBTemplateRegistration.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation SBNotificationHubHelper

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static NSString *const domain = @"WindowsAzureMessaging";

+ (NSString *)createHashWithData:(NSData *)data {

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    NSString *hash = [self toBase64:(unsigned char *)digest length:CC_SHA1_DIGEST_LENGTH];

    return [[[hash stringByReplacingOccurrencesOfString:@"=" withString:@""] stringByReplacingOccurrencesOfString:@"+" withString:@"-"]
        stringByReplacingOccurrencesOfString:@"/"
                                  withString:@"_"];
}

+ (NSString *)signString:(NSString *)str withKeyData:(const char *)cKey keyLength:(NSInteger)keyLength {
    const char *cData = [str cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, keyLength, cData, strlen(cData), cHMAC);

    NSData *hmac = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA256_DIGEST_LENGTH];

    return [hmac base64EncodedStringWithOptions:0];
}

+ (NSString *)signString:(NSString *)str withKey:(NSString *)key {
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    return [self signString:str withKeyData:cKey keyLength:strlen(cKey)];
}

+ (NSString *)urlEncode:(NSString *)urlString {
    NSMutableString *encodedString = [NSMutableString string];
    const char *sourceUTF8 = [urlString cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned long length = strlen(sourceUTF8);
    for (unsigned long i = 0; i < length; i++) {
        const char currentChar = sourceUTF8[i];
        if (currentChar == '.' || currentChar == '-' || currentChar == '_' || currentChar == '~' ||
            (currentChar >= 'a' && currentChar <= 'z') || (currentChar >= 'A' && currentChar <= 'Z') ||
            (currentChar >= '0' && currentChar <= '9')) {
            [encodedString appendFormat:@"%c", currentChar];
        } else {
            [encodedString appendFormat:@"%%%02X", currentChar];
        }
    }
    return encodedString;
}

+ (NSString *)urlDecode:(NSString *)urlString {
    return [[urlString stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByRemovingPercentEncoding];
}

+ (NSString *)toBase64:(unsigned char *)data length:(NSInteger)length {

    NSMutableString *dest = [[NSMutableString alloc] initWithString:@""];

    unsigned char *tempData = (unsigned char *)data;
    NSInteger srcLen = length;

    for (int i = 0; i < srcLen; i += 3) {
        NSInteger value = 0;
        for (int j = i; j < (i + 3); j++) {
            value <<= 8;

            if (j < length) {
                value |= (0xFF & tempData[j]);
            }
        }

        [dest appendFormat:@"%c", encodingTable[(value >> 18) & 0x3F]];
        [dest appendFormat:@"%c", encodingTable[(value >> 12) & 0x3F]];
        [dest appendFormat:@"%c", (i + 1) < length ? encodingTable[(value >> 6) & 0x3F] : '='];
        [dest appendFormat:@"%c", (i + 2) < length ? encodingTable[(value >> 0) & 0x3F] : '='];
    }

    return dest;
}

+ (NSData *)fromBase64:(NSString *)str {
    return [[NSData alloc] initWithBase64EncodedString:str options:0];
}

+ (NSString *)convertTagSetToString:(NSSet *)tagSet {
    if (!tagSet) {
        return @"";
    }

    NSMutableString *tags;

    for (NSString *element in tagSet) {
        if (!tags) {
            tags = [[NSMutableString alloc] initWithString:element];
        } else {
            [tags appendString:[NSString stringWithFormat:@",%@", element]];
        }
    }

    return tags;
}

+ (NSError *)errorForNullDeviceToken {
    return [SBNotificationHubHelper errorWithMsg:@"Device Token can't be nil." code:-1];
}

+ (NSError *)errorForReservedTemplateName {
    return [SBNotificationHubHelper errorWithMsg:@"TemplateName is conflict with reservered ones." code:-1];
}

+ (NSError *)errorForInvalidTemplateName {
    return [SBNotificationHubHelper errorWithMsg:@"TemplateName can't contains ':'." code:-1];
}

+ (NSError *)errorWithMsg:(NSString *)msg code:(NSInteger)code {
    NSMutableDictionary *details = [NSMutableDictionary dictionary];
    [details setValue:msg forKey:NSLocalizedDescriptionKey];
    return [[NSError alloc] initWithDomain:domain code:code userInfo:details];
}

+ (NSError *)registrationNotFoundError {
    NSMutableDictionary *details = [NSMutableDictionary dictionary];
    [details setValue:@"Registration is not found." forKey:NSLocalizedDescriptionKey];
    return [[NSError alloc] initWithDomain:domain code:404 userInfo:details];
}

+ (NSDictionary *)parseConnectionString:(NSString *)connectionString {
    NSArray *allField = [connectionString componentsSeparatedByString:@";"];

    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    NSString *previousLeft = @"";
    for (uint i = 0; i < [allField count]; i++) {
        NSString *currentField = (NSString *)[allField objectAtIndex:i];

        if ((i + 1) < [allField count]) {
            // if next field does not start with known name, this ';' will be ignored
            NSString *lowerCaseNextField = [(NSString *)[allField objectAtIndex:(i + 1)] lowercaseString];
            if (!([lowerCaseNextField hasPrefix:@"endpoint="] || [lowerCaseNextField hasPrefix:@"sharedaccesskeyname="] ||
                  [lowerCaseNextField hasPrefix:@"sharedaccesskey="] || [lowerCaseNextField hasPrefix:@"sharedsecretissuer="] ||
                  [lowerCaseNextField hasPrefix:@"sharedsecretvalue="] || [lowerCaseNextField hasPrefix:@"stsendpoint="])) {
                previousLeft = [NSString stringWithFormat:@"%@%@;", previousLeft, currentField];
                continue;
            }
        }

        currentField = [NSString stringWithFormat:@"%@%@", previousLeft, currentField];
        previousLeft = @"";

        NSArray *keyValuePairs = [currentField componentsSeparatedByString:@"="];
        if ([keyValuePairs count] < 2) {
            break;
        }

        NSString *keyName = [(NSString *)[keyValuePairs objectAtIndex:0] lowercaseString];

        NSString *keyValue = [currentField substringFromIndex:([keyName length] + 1)];
        if ([keyName isEqualToString:@"endpoint"]) {
            {
                keyValue = [[SBNotificationHubHelper modifyEndpoint:[NSURL URLWithString:keyValue] scheme:@"https"] absoluteString];
            }
        }

        [result setObject:keyValue forKey:keyName];
    }

    return result;
}

// add last slash, and change to desinged scheme
+ (NSURL *)modifyEndpoint:(NSURL *)endPoint scheme:(NSString *)scheme {
    NSString *endpointAbsoluteString = [endPoint absoluteString];
    NSString *modifiedEndpoint = [NSString stringWithString:endpointAbsoluteString];

    if (![modifiedEndpoint hasSuffix:@"/"]) {
        modifiedEndpoint = [NSString stringWithFormat:@"%@/", modifiedEndpoint];
    }

    NSInteger position = [modifiedEndpoint rangeOfString:@":"].location;
    if (position == NSNotFound) {
        modifiedEndpoint = [scheme stringByAppendingFormat:@"://%@", modifiedEndpoint];
    } else {
        modifiedEndpoint = [scheme stringByAppendingFormat:@"%@", [modifiedEndpoint substringFromIndex:position]];
    }

    return [NSURL URLWithString:modifiedEndpoint];
}

+ (NSString *)nameOfRegistration:(SBRegistration *)registration {
    if ([registration class] == [SBTemplateRegistration class]) {
        return ((SBTemplateRegistration *)registration).templateName;
    } else {
        return [SBRegistration Name];
    }
}

@end
