#import "NSDictionary+cliqcliq.h"


@implementation NSDictionary (cliqcliq)


+ (NSDictionary *)dictionaryWithPlistData:(NSData *)data {
  NSPropertyListFormat format;
  NSString *errorString = nil;
  NSDictionary *output = [NSPropertyListSerialization propertyListFromData:data
                                                      mutabilityOption:kCFPropertyListImmutable
                                                      format:&format
                                                      errorDescription:&errorString];
  if (errorString) {
    NSLog(@"Error parsing plist: %@", errorString);
  }
  
  return output;
}


- (id)valueForKey:(NSString *)key defaultValue:(id)defaultValue {
  id output = [self valueForKey:key];
  return output && ![output isKindOfClass:[NSNull class]] ? output : defaultValue;
}


@end
