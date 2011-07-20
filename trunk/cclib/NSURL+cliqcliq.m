#import "NSURL+cliqcliq.h"

#import "CcHttpRequest.h"


@implementation NSURL (cliqcliq)


- (NSURL *)addGetParameters:(NSDictionary *)params {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",
                                                           [self absoluteString],
                                                           [CcHttpRequest encode:params]]];
}


+ (NSURL *)avatarUrlForUserWithGuid:(NSString *)userGuid large:(BOOL)large {
  return [NSURL URLWithStringWithFormat:@"%@/avatars/%@-%@.jpg",
                                        kImagesServerRootUrl,
                                        userGuid,
                                        large ? @"large" : @"small"];
}


+ (NSURL *)URLWithStringWithFormat:(NSString *)format, ... {
  va_list arguments;
  va_start(arguments, format);
  NSString *output = [[[NSString alloc] initWithFormat:format
                                        arguments:arguments] autorelease];
  va_end(arguments);

  return [NSURL URLWithString:output];
}


@end