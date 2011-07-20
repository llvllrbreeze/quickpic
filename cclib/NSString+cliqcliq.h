#import <Foundation/Foundation.h>


@interface NSString (cliqcliq)

- (NSDate *)date;
+ (NSString *)deviceKey;
- (NSString *)md5;
+ (NSString *)stringWithDate:(NSDate *)date;
+ (NSString *)stringWithUtf8Data:(NSData *)data;
- (NSURL *)url;
+ (NSData *)utf8DataWithFormat:(NSString *)format, ...;

@end
