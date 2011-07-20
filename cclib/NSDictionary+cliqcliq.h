#import <Foundation/Foundation.h>


@interface NSDictionary (cliqcliq)

+ (NSDictionary *)dictionaryWithPlistData:(NSData *)data;
- (id)valueForKey:(NSString *)key defaultValue:(id)defaultValue;

@end
