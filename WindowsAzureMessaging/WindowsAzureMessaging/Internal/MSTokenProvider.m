//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSTokenProvider.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation MSTokenProvider {

  @private
    NSString *_sharedAccessKey;
    NSString *_sharedAccessKeyName;
    NSString *_sharedSecret;
    NSString *_sharedSecretIssurer;
    NSURL *_stsHostName;
    NSURL *_serviceEndPoint;
}

@synthesize timeToExpireinMins;

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static NSString *decodingTableLock = @"decodingTableLock";

- (instancetype)initWithConnectionDictionary:(NSDictionary *)connectionDictionary {
    if ((self = [super init]) != nil) {
        if (![self isSuccessfullyInitWithConnectionString:connectionDictionary]) {
            return nil;
        }
    }

    return self;
}

+ (MSTokenProvider *)createFromConnectionDictionary:(NSDictionary *)connectionDictionary {
    return [[MSTokenProvider alloc] initWithConnectionDictionary:connectionDictionary];
}

- (NSString *)generateSharedAccessTokenWithUrl:(NSString *)audienceUri {
    // time to live in seconds
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    int totalSeconds = interval + timeToExpireinMins * 60;
    NSString *expiresOn = [NSString stringWithFormat:@"%d", totalSeconds];

    audienceUri = [[audienceUri lowercaseString] stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"];
    audienceUri = [[self urlEncode:audienceUri] lowercaseString];

    NSString *signature = [self signString:[audienceUri stringByAppendingFormat:@"\n%@", expiresOn] withKey:_sharedAccessKey];
    signature = [self urlEncode:signature];

    NSString *token = [NSString
        stringWithFormat:@"SharedAccessSignature sr=%@&sig=%@&se=%@&skn=%@", audienceUri, signature, expiresOn, _sharedAccessKeyName];

    return token;
}

- (BOOL)isSuccessfullyInitWithConnectionString:(NSDictionary *)connectionDictionary {
    timeToExpireinMins = 20;

    NSString *endpoint = [connectionDictionary objectForKey:@"endpoint"];
    if (endpoint) {
        _serviceEndPoint = [[NSURL alloc] initWithString:endpoint];
    }

    NSString *stsendpoint = [connectionDictionary objectForKey:@"stsendpoint"];
    if (stsendpoint) {
        _stsHostName = [[NSURL alloc] initWithString:stsendpoint];
    }

    _sharedAccessKey = [connectionDictionary objectForKey:@"sharedaccesskey"];
    _sharedAccessKeyName = [connectionDictionary objectForKey:@"sharedaccesskeyname"];
    _sharedSecret = [connectionDictionary objectForKey:@"sharedsecretvalue"];
    _sharedSecretIssurer = [connectionDictionary objectForKey:@"sharedsecretissuer"];

    // validation
    if (_serviceEndPoint == nil || [_serviceEndPoint host] == nil) {
        NSLog(@"%@", @"Endpoint is missing or not in URL format in connectionString.");
        return NO;
    }

    if ((_sharedAccessKey == nil || _sharedAccessKeyName == nil) && _sharedSecret == nil) {
        NSLog(@"%@", @"Security information is missing in connectionString.");
        return NO;
    }

    if (_stsHostName == nil) {
        NSString *nameSpace = [[[_serviceEndPoint host] componentsSeparatedByString:@"."] objectAtIndex:0];
        _stsHostName =
            [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://%@-sb.accesscontrol.windows.net", nameSpace]];
    } else {
        if ([_stsHostName host] == nil) {
            NSLog(@"%@", @"StsHostname is not in URL format in connectionString.");
            return NO;
        }

        _stsHostName = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://%@", [_stsHostName host]]];
    }

    if (_sharedSecret && !_sharedSecretIssurer) {
        _sharedSecretIssurer = @"owner";
    }

    return YES;
}

- (NSString *)toBase64:(unsigned char *)data length:(NSInteger)length {

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

- (NSString *)signString:(NSString *)str withKeyData:(const char *)cKey keyLength:(NSInteger)keyLength {
    const char *cData = [str cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, keyLength, cData, strlen(cData), cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA256_DIGEST_LENGTH];

    NSString *signature = [self toBase64:(unsigned char *)[HMAC bytes] length:[HMAC length]];

    return signature;
}

- (NSString *)signString:(NSString *)str withKey:(NSString *)key {
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    return [self signString:str withKeyData:cKey keyLength:strlen(cKey)];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (NSString *)urlEncode:(NSString *)urlString {
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)urlString, NULL,
                                                                        CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
}
#pragma GCC diagnostic pop

- (NSString *)urlDecode:(NSString *)urlString {
    return [[urlString stringByReplacingOccurrencesOfString:@"+"
                                                 withString:@" "] stringByRemovingPercentEncoding];
}

@end
