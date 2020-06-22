//----------------------------------------------------------------
//  Copyright (c) Microsoft Corporation. All rights reserved.
//----------------------------------------------------------------

#import "MSTokenProvider.h"
#import "MSTokenProvider+Private.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation MSTokenProvider

@synthesize timeToExpireinMins;

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

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
    int totalSeconds = round(interval) + self.timeToExpireinMins * 60;
    NSString *expiresOn = [NSString stringWithFormat:@"%d", totalSeconds];

    audienceUri = [[audienceUri lowercaseString] stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"];
    audienceUri = [[self urlEncode:audienceUri] lowercaseString];

    NSString *signature = [self signString:[audienceUri stringByAppendingFormat:@"\n%@", expiresOn] withKey:self.sharedAccessKey];
    signature = [self urlEncode:signature];

    NSString *token = [NSString
                       stringWithFormat:@"SharedAccessSignature sr=%@&sig=%@&se=%@&skn=%@", audienceUri, signature, expiresOn, self.sharedAccessKeyName];

    return token;
}

- (BOOL)isSuccessfullyInitWithConnectionString:(NSDictionary *)connectionDictionary {
    self.timeToExpireinMins = 20;

    NSString *endpoint = [connectionDictionary objectForKey:@"endpoint"];
    if (endpoint) {
        self.serviceEndPoint = [[NSURL alloc] initWithString:endpoint];
    }

    NSString *stsendpoint = [connectionDictionary objectForKey:@"stsendpoint"];
    if (stsendpoint) {
        self.stsHostName = [[NSURL alloc] initWithString:stsendpoint];
    }

    self.sharedAccessKey = [connectionDictionary objectForKey:@"sharedaccesskey"];
    self.sharedAccessKeyName = [connectionDictionary objectForKey:@"sharedaccesskeyname"];
    self.sharedSecret = [connectionDictionary objectForKey:@"sharedsecretvalue"];
    self.sharedSecretIssurer = [connectionDictionary objectForKey:@"sharedsecretissuer"];

    // validation
    if (self.serviceEndPoint == nil || [self.serviceEndPoint host] == nil) {
        NSLog(@"%@", @"Endpoint is missing or not in URL format in connectionString.");
        return NO;
    }

    if ((self.sharedAccessKey == nil || self.sharedAccessKeyName == nil) && self.sharedSecret == nil) {
        NSLog(@"%@", @"Security information is missing in connectionString.");
        return NO;
    }

    if (self.stsHostName == nil) {
        NSString *nameSpace = [[[self.serviceEndPoint host] componentsSeparatedByString:@"."] objectAtIndex:0];
        self.stsHostName =
            [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://%@-sb.accesscontrol.windows.net", nameSpace]];
    } else {
        if ([self.stsHostName host] == nil) {
            NSLog(@"%@", @"StsHostname is not in URL format in connectionString.");
            return NO;
        }

        self.stsHostName = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://%@", [self.stsHostName host]]];
    }

    if (self.sharedSecret && !self.sharedSecretIssurer) {
        self.sharedSecretIssurer = @"owner";
    }

    return YES;
}

- (NSString *)toBase64:(const unsigned char *)data length:(NSInteger)length {

    NSMutableString *dest = [[NSMutableString alloc] initWithString:@""];

    const unsigned char *tempData = data;
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

    NSString *signature = [self toBase64:(const unsigned char *)[HMAC bytes] length:[HMAC length]];

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
