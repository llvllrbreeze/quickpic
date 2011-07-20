#import <Foundation/Foundation.h>


@interface NSURL (cliqcliq)

- (NSURL *)addGetParameters:(NSDictionary *)params;
+ (NSURL *)avatarUrlForUserWithGuid:(NSString *)userGuid large:(BOOL)large;
+ (NSURL *)URLWithStringWithFormat:(NSString *)format, ...;

@end
