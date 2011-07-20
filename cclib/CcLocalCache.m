#import "CcLocalCache.h"

#import "CcConfiguration.h"
#import "NSString+cliqcliq.h"


@interface CcLocalCache ()
  + (NSString *)baseUrlString:(NSURL *)url;
  + (BOOL)cacheFileHasExpired:(NSString *)fileName;
  + (NSData *)dataFromFileInTempDirectory:(NSString*)cacheKey;
  + (NSString *)keyForURL:(NSURL *)url;
  + (NSString *)keyForURL:(NSURL *)url duration:(NSTimeInterval)duration;
  + (NSString *)tempDirectory:(NSString *)appendPathComponent;
@end


@implementation CcLocalCache


#pragma mark -


+ (void)cacheData:(NSData *)data forUrl:(NSURL *)url duration:(NSTimeInterval)duration {
  NSString *cacheKey = [CcLocalCache keyForURL:url duration:duration];
  if (cacheKey) {
    NSString *fileName = [CcLocalCache tempDirectory:cacheKey];
    [data writeToFile:fileName atomically:YES];
  }
}


+ (void)cleanup {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *directoryContents =
      [fileManager directoryContentsAtPath:[CcLocalCache tempDirectory:nil]];
  for (NSString *fileName in directoryContents) {
    if (![fileName hasPrefix:@"cLiQClIq_"]) {
      continue;
    }

    if ([CcLocalCache cacheFileHasExpired:fileName]) {
      NSError *err = nil;        
      [fileManager removeItemAtPath:[CcLocalCache tempDirectory:fileName] error:&err];
    }
  }
}


+ (void)clearCache {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *directoryContents =
      [fileManager directoryContentsAtPath:[CcLocalCache tempDirectory:nil]];
  for (NSString *fileName in directoryContents) {
    if (![fileName hasPrefix:@"cLiQClIq_"]) {
      continue;
    }

    NSError *err = nil;
    [fileManager removeItemAtPath:[CcLocalCache tempDirectory:fileName] error:&err];
  }
}


+ (NSData *)dataForUrl:(NSURL *)url duration:(NSTimeInterval)duration {
  #ifdef DISABLE_LOCAL_CACHE
    return nil;
  #endif

  NSString *cacheKey = [CcLocalCache keyForURL:url duration:duration];
  if (!cacheKey) {
    return nil;
  }
  
  NSData *output = [CcLocalCache dataFromFileInTempDirectory:cacheKey];

  return output;
}


+ (void)removeCachedDataForUrl:(NSURL *)url {
  NSString *cacheKeyPrefix = [[CcLocalCache keyForURL:url] substringToIndex:41];

  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *directoryContents =
      [fileManager directoryContentsAtPath:[CcLocalCache tempDirectory:nil]];
  for (NSString *fileName in directoryContents) {
    if (![fileName hasPrefix:@"cLiQClIq_"]) {
      continue;
    }

    if ([fileName hasPrefix:cacheKeyPrefix]) {
      NSError *err = nil;
      [fileManager removeItemAtPath:[CcLocalCache tempDirectory:fileName] error:&err];
    }
  }
}


+ (void)removeCachedDataForUrlBase:(NSURL *)url {
  [CcLocalCache removeCachedDataForUrl:[NSURL URLWithString:[CcLocalCache baseUrlString:url]]];
}


#pragma mark Private


+ (NSString *)baseUrlString:(NSURL *)url {
  return [NSString stringWithFormat:
      @"%@://%@%@%@",
      [url scheme],
      [url host],
      [url port] ? [NSString stringWithFormat:@":%d", [url port]] : @"",
      [url path]];
}


+ (BOOL)cacheFileHasExpired:(NSString *)fileName {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSDictionary *fileAttributes =
      [fileManager fileAttributesAtPath:[CcLocalCache tempDirectory:fileName] traverseLink:YES];
  NSDate *modificationDate = [fileAttributes valueForKey:NSFileModificationDate];

  NSRange rangeOf__ = [fileName rangeOfString:@"__"];
  if (rangeOf__.location == NSNotFound) {
    return YES;
  } else {
    NSString *durationString =
        [fileName substringFromIndex:rangeOf__.location + rangeOf__.length];
    NSDate *maxTimeAgo = [[NSDate date] addTimeInterval:-[durationString longLongValue]];
    if ([modificationDate compare:maxTimeAgo] == NSOrderedAscending) {
      return YES;
    }
  }
  
  return NO;
}


+ (NSData *)dataFromFileInTempDirectory:(NSString*)cacheKey {
  NSString *fileName = [CcLocalCache tempDirectory:cacheKey];

  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([CcLocalCache cacheFileHasExpired:cacheKey]) {
    NSError *err = nil;        
    [fileManager removeItemAtPath:fileName error:&err];
  }

  return [NSData dataWithContentsOfFile:fileName];
}


+ (NSString *)keyForURL:(NSURL *)url {
  if (!url) {
    return nil;
  }
  
  NSString *baseUrlString = [CcLocalCache baseUrlString:url];
  NSString *queryString = [url query];
  if (!queryString) {
    queryString = @"";
  }
  
  return [NSString stringWithFormat:@"cLiQClIq_%@_%@", [baseUrlString md5], [queryString md5]];
}


+ (NSString *)keyForURL:(NSURL *)url duration:(NSTimeInterval)duration {
  return [[CcLocalCache keyForURL:url] stringByAppendingFormat:@"__%ld", (long long) duration];
}


+ (NSString *)tempDirectory:(NSString *)appendPathComponent {
  NSString *tempDir = NSTemporaryDirectory();

  if (appendPathComponent) {
    return [tempDir stringByAppendingPathComponent:appendPathComponent];
  } else {
    return tempDir;
  }
}


@end
