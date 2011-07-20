#import "NSString+cliqcliq.h"

#import <CommonCrypto/CommonDigest.h>

#import "CcConfiguration.h"


@implementation NSString (cliqcliq)


- (NSDate *)date {
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  [dateFormatter setDateFormat:@"%Y-%m-%d %H:%M:%S"];
  return [dateFormatter dateFromString:self];
}


+ (NSString *)deviceKey {
  NSString *rawKey = [NSString stringWithFormat:@"%@%@",
                                                kIphoneSecretKey,
                                                [UIDevice currentDevice].uniqueIdentifier];
  return [rawKey md5];
}


- (NSString *)md5 {
  const char* str = [self UTF8String];
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(str, strlen(str), result);
  
  return [NSString stringWithFormat:
              @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                  result[0], result[1], result[2], result[3], result[4], result[5], result[6],
                  result[7], result[8], result[9], result[10], result[11], result[12], result[13],
                  result[14], result[15]];
}


+ (NSString *)stringWithDate:(NSDate *)date {
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  [dateFormatter setDateFormat:@"%Y-%m-%d %H:%M:%S"];
  return [dateFormatter stringFromDate:date];
}


+ (NSString *)stringWithUtf8Data:(NSData *)data {
  return [[[NSString alloc] initWithBytes:[data bytes]
                            length:[data length]
                            encoding:NSUTF8StringEncoding] autorelease];
}


- (NSURL *)url {
  return [NSURL URLWithString:self];
}


+ (NSData *)utf8DataWithFormat:(NSString *)format, ... {
  va_list arguments;
  va_start(arguments, format);
  NSString *output = [[[NSString alloc] initWithFormat:format
                                        arguments:arguments] autorelease];
  va_end(arguments);

  return [output dataUsingEncoding:NSUTF8StringEncoding];
}


@end
