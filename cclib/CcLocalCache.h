#import <Foundation/Foundation.h>


@interface CcLocalCache : NSObject {

}

+ (void)cacheData:(NSData *)data forUrl:(NSURL *)url duration:(NSTimeInterval)duration;
+ (void)cleanup;
+ (void)clearCache;
+ (NSData *)dataForUrl:(NSURL *)url duration:(NSTimeInterval)duration;
+ (void)removeCachedDataForUrl:(NSURL *)url;
+ (void)removeCachedDataForUrlBase:(NSURL *)url;

@end
