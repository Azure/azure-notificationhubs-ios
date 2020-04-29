#import <Foundation/Foundation.h>
#import "MSInstallation.h"
#import "MSInstallationManager.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

@implementation MSInstallationManager

const int timeToExpireinMins = 20;
static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static char decodingTable[128];
static NSString* decodingTableLock = @"decodingTableLock";


+ (MSInstallation *) initInstallationWith:(NSString *)connectionString withHubName:(NSString *) hubname withDeviceToken: (NSString *) deviceToken{
    NSDictionary *parsedConnectionString = [self parseConnectionString: connectionString];
    
    NSString *endpoint = [parsedConnectionString objectForKey:@"endpoint"];

    NSString *installationId = [[NSUUID UUID] UUIDString];

    NSString *url = [NSString stringWithFormat:@"https://%@/%@/installations/%@?api-version=2017-04", endpoint, hubname, installationId];
    
    NSString *accessKeyName = [parsedConnectionString objectForKey:@"sharedaccesskeyname"];
    NSString *sharedAccessKey = [parsedConnectionString objectForKey:@"sharedaccesskey"];

    NSString *sasToken = [MSInstallationManager prepareSharedAccessTokenWithUrl:url sharedAccessKeyName:accessKeyName sharedAccessKey:sharedAccessKey];
    
    NSDictionary *installationJson = @{
           @"installationId" : installationId,
           @"platform" : @"APNS",
           @"pushChannel" : deviceToken
    };
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:installationJson
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    
    return [MSInstallation new];
}

+ (NSData*) fromBase64: (NSString*) str{
    
    if(decodingTable['B'] != 1)
    {
        @synchronized(decodingTableLock)
        {
            if(decodingTable['B'] != 1)
            {
                memset(decodingTable, 0, 128);
                int length = (sizeof encodingTable);
                for (int i = 0; i < length; i++)
                {
                    decodingTable[encodingTable[i]] = i;
                }
            }
        }
    }

    NSData* inputData = [str dataUsingEncoding:NSASCIIStringEncoding];
    const char* input =inputData.bytes;
    NSInteger inputLength = inputData.length;
    
    if ((input == NULL) || (inputLength% 4 != 0)) {
        return nil;
    }
    
    while (inputLength > 0 && input[inputLength - 1] == '=') {
        inputLength--;
    }
    
    NSUInteger outputLength = inputLength * 3 / 4;
    NSMutableData* outputData = [NSMutableData dataWithLength:outputLength];
    uint8_t* output = outputData.mutableBytes;
    
    NSUInteger outputPos = 0;
    for (int i=0; i<inputLength; i += 4)
    {
        char i0 = input[i];
        char i1 = input[i+1];
        char i2 = i+2 < inputLength ? input[i+2] : 'A';
        char i3 = i+3 < inputLength ? input[i+3] : 'A';
        
        char result =(decodingTable[i0] << 2) | (decodingTable[i1] >> 4);
        output[outputPos++] =  result;
        if (outputPos < outputLength) {
            output[outputPos++] = ((decodingTable[i1] & 0xf) << 4) | (decodingTable[i2] >> 2);
        }
        if (outputPos < outputLength) {
            output[outputPos++] = ((decodingTable[i2] & 0x3) << 6) | decodingTable[i3];
        }
    }
    
    return outputData;
}

+ (NSString*) toBase64: (unsigned char*) data length:(NSInteger) length{
    
    NSMutableString *dest = [[NSMutableString alloc] initWithString:@""];
    
    unsigned char * tempData = (unsigned char *)data;
    NSInteger srcLen = length;
    
    for (int i=0; i<srcLen; i += 3)
    {
        NSInteger value = 0;
        for (int j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & tempData[j]);
            }
        }
        
        [dest appendFormat:@"%c", encodingTable[(value >> 18) & 0x3F]];
        [dest appendFormat:@"%c", encodingTable[(value >> 12) & 0x3F]];
        [dest appendFormat:@"%c", (i + 1) < length ? encodingTable[(value >> 6)  & 0x3F] : '='];
        [dest appendFormat:@"%c", (i + 2) < length ? encodingTable[(value >> 0)  & 0x3F] : '='];
    }
    
    return dest;
}

+ (NSString*) signString: (NSString*)str withKeyData:(const char*) cKey keyLength:(NSInteger) keyLength{
    const char *cData = [str cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256, cKey, keyLength, cData, strlen(cData), cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA256_DIGEST_LENGTH];

    NSString* signature = [self toBase64:(unsigned char *)[HMAC bytes] length:[HMAC length]];

    return signature;
}

+ (NSString*) signString: (NSString*)str withKey:(NSString*) key{
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    return [self signString:str withKeyData:cKey keyLength:strlen(cKey)];
}

+ (NSString*) urlEncode: (NSString*)urlString{
    return (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)urlString, NULL,CFSTR("!*'();:@&=+$,/?%#[]"),  kCFStringEncodingUTF8);
}

+ (NSString*) urlDecode: (NSString*)urlString{
    return [[urlString
      stringByReplacingOccurrencesOfString:@"+" withString:@" "]
     stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *) prepareSharedAccessTokenWithUrl:(NSString*)audienceUri sharedAccessKeyName:accessKeyName sharedAccessKey:(NSString*) accessKey
{
    // time to live in seconds
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    int totalSeconds = interval + timeToExpireinMins * 60;
    NSString* expiresOn = [NSString stringWithFormat:@"%d", totalSeconds];

    audienceUri = [[audienceUri lowercaseString] stringByReplacingOccurrencesOfString:@"https://" withString:@"http://"];
    audienceUri = [[MSInstallationManager urlEncode:audienceUri] lowercaseString];

    NSString* signature = [MSInstallationManager signString:[audienceUri stringByAppendingFormat:@"\n%@",expiresOn] withKey:accessKey];
    signature = [MSInstallationManager urlEncode:signature];

    NSString* token = [NSString stringWithFormat:@"SharedAccessSignature sr=%@&sig=%@&se=%@&skn=%@", audienceUri, signature, expiresOn, accessKeyName];

    return token;
}

+ (NSDictionary*) parseConnectionString:(NSString*) connectionString
{
    NSArray *allField = [connectionString componentsSeparatedByString:@";"];
    
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    
    NSString* previousLeft = @"";
    for (int i=0; i< [allField count]; i++) {
        NSString* currentField = (NSString*)[allField objectAtIndex:i];
        
        if( (i+1) < [allField count])
        {
            // if next field does not start with known name, this ';' will be ignored
            NSString* lowerCaseNextField = [(NSString*)[allField objectAtIndex:(i+1)] lowercaseString];
            if(!([lowerCaseNextField hasPrefix:@"endpoint="] ||
                 [lowerCaseNextField hasPrefix:@"sharedaccesskeyname="] ||
                 [lowerCaseNextField hasPrefix:@"sharedaccesskey="] ||
                 [lowerCaseNextField hasPrefix:@"sharedsecretissuer="] ||
                 [lowerCaseNextField hasPrefix:@"sharedsecretvalue="] ||
                 [lowerCaseNextField hasPrefix:@"stsendpoint="] ))
            {
                previousLeft = [NSString stringWithFormat:@"%@%@;",previousLeft,currentField];
                continue;
            }
        }
        
        currentField = [NSString stringWithFormat:@"%@%@",previousLeft,currentField];
        previousLeft = @"";
        
        NSArray *keyValuePairs = [currentField componentsSeparatedByString:@"="];
        if([keyValuePairs count] < 2)
        {
            break;
        }
        
        NSString* keyName = [[keyValuePairs objectAtIndex: 0] lowercaseString];
        
        NSString* keyValue = [currentField substringFromIndex:([keyName length] +1)];
        if([keyName isEqualToString:@"endpoint"]){
            {
                keyValue = [[MSInstallationManager modifyEndpoint:[NSURL URLWithString:keyValue] scheme:@"https"] absoluteString];
            }
        }
        
        [result setObject:keyValue forKey:keyName];
    }
    
    return result;
}

+ (NSURL*) modifyEndpoint:(NSURL*)endPoint scheme:(NSString*)scheme
{
    NSString* modifiedEndpoint = [NSString stringWithString:[endPoint absoluteString]];
    
    if(![modifiedEndpoint hasSuffix:@"/"])
    {
        modifiedEndpoint = [NSString stringWithFormat:@"%@/",modifiedEndpoint];
    }
    
    NSInteger position = [modifiedEndpoint rangeOfString:@":"].location;
    if( position == NSNotFound)
    {
        modifiedEndpoint = [scheme stringByAppendingFormat:@"://%@",modifiedEndpoint];
    }
    else
    {
        modifiedEndpoint = [scheme stringByAppendingFormat:@"%@",[modifiedEndpoint substringFromIndex:position]];
    }
    
    return [NSURL URLWithString:modifiedEndpoint];
}

@end
