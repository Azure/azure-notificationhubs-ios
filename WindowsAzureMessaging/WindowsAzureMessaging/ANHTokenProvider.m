//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "ANHTokenProvider.h"
#import <CommonCrypto/CommonHMAC.h>

@interface ANHTokenProvider ()

@property(nonatomic, strong) ANHConnection *connectionString;

@end

@implementation ANHTokenProvider

- (instancetype)initWithConnectionString:(ANHConnection *)connectionString {
    if ((self = [super init]) != nil) {
        _connectionString = connectionString;
        _timeToExpireinMins = 20;
    }

    return self;
}

- (NSString *)generateSharedAccessTokenWithUrl:(NSString *)audienceUri {
    // time to live in seconds
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    double totalSeconds = interval + _timeToExpireinMins * 60;
    NSString *expiresOn = [NSString stringWithFormat:@"%.f", totalSeconds];

    audienceUri = [[audienceUri lowercaseString] stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"];
    audienceUri = [[self urlEncode:audienceUri] lowercaseString];

    NSString *signature = [self signString:[audienceUri stringByAppendingFormat:@"\n%@", expiresOn] withKey:_connectionString.sharedAccessKey];
    signature = [self urlEncode:signature];

    NSString *token = [NSString
        stringWithFormat:@"SharedAccessSignature sr=%@&sig=%@&se=%@&skn=%@", audienceUri, signature, expiresOn, _connectionString.sharedAccessKeyName];

    return token;
}

- (NSString *)signString:(NSString *)str withKeyData:(const char *)cKey keyLength:(NSInteger)keyLength {
    const char *cData = [str cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, keyLength, cData, strlen(cData), cHMAC);

    NSData *hmac = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA256_DIGEST_LENGTH];

    return [hmac base64EncodedStringWithOptions:0];
}

- (NSString *)signString:(NSString *)str withKey:(NSString *)key {
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    return [self signString:str withKeyData:cKey keyLength:strlen(cKey)];
}

- (NSString *)urlEncode:(NSString *)urlString {
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

- (NSString *)urlDecode:(NSString *)urlString {
    return [[urlString stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByRemovingPercentEncoding];
}

@end
