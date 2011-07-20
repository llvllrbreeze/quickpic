#import "CcMediaDataSourceBase.h"

#import "CcMediaDataAvailabilityChangedDelegate.h"


#define MAX_DELEGATES 10


@implementation CcMediaDataSourceBase


#pragma mark Initialization


- (id)init {
  if (self = [super init]) {
    int itemSize = sizeof(NSObject <CcMediaDataAvailabilityChangedDelegate> *);
    delegates =
        (NSObject <CcMediaDataAvailabilityChangedDelegate> **) malloc(itemSize * MAX_DELEGATES);
    numDelegates = 0;
  }
  return self;
}


#pragma mark Cleanup


- (void)dealloc {
  free(delegates);
  delegates = nil;

  [super dealloc];
}


#pragma mark CcMediaDataSource Methods


- (void)addDelegate:(NSObject <CcMediaDataAvailabilityChangedDelegate> *)delegate {
  delegates[numDelegates++] = delegate;
}


- (void)cancel {
  [NSException raise:@"Unsupported method" format:@"cancel"];
}


- (NSString *)getLastError {
  [NSException raise:@"Unsupported method" format:@"getLastError"];
  return nil;
}


- (NSString *)getTitle {
  [NSException raise:@"Unsupported method" format:@"getTitle"];
  return nil;
}


- (BOOL)hadError {
  [NSException raise:@"Unsupported method" format:@"hadError"];
  return NO;
}


- (BOOL)isReady {
  [NSException raise:@"Unsupported method" format:@"isReady"];
  return NO;
}


- (BOOL)isSearchable {
  return NO;
}


- (CcMedia *)mediaAtIndex:(int)index {
  [NSException raise:@"Unsupported method" format:@"mediaAtIndex:"];
  return nil;
}


- (BOOL)mediaAtIndexIsReady:(int)index {
  [NSException raise:@"Unsupported method" format:@"mediaAtIndexIsReady:"];
  return NO;
}


- (int)mediaCount {
  [NSException raise:@"Unsupported method" format:@"mediaCount"];
  return 0;
}


- (int)mediaIdForMediaAtIndex:(int)index {
  [NSException raise:@"Unsupported method" format:@"mediaIdForMediaAtIndex:"];
  return 0;
}


- (void)removeDelegate:(NSObject <CcMediaDataAvailabilityChangedDelegate> *)delegate {
  for (int delegateIndex = numDelegates - 1; delegateIndex >= 0; delegateIndex--) {
    if (delegates[delegateIndex] == delegate) {
      delegates[delegateIndex] = nil;

      int itemSize = sizeof(NSObject <CcMediaDataAvailabilityChangedDelegate> *);
      memmove(delegates + delegateIndex,
              delegates + delegateIndex + 1,
              itemSize * (numDelegates - delegateIndex - 1));

      numDelegates--;
    }
  }
}


- (BOOL)requestMediaAtIndex:(int)index {
  [NSException raise:@"Unsupported method" format:@"requestMediaAtIndex:"];
  return NO;
}


- (BOOL)requestThumbnailAtIndex:(int)index {
  [NSException raise:@"Unsupported method" format:@"requestThumbnailAtIndex:"];
  return NO;
}


- (void)setSearchQuery:(NSString *)query {
  [NSException raise:@"Unsupported method" format:@"setSearchQuery:"];
}


- (NSString *)sourceAuthorForMediaAtIndex:(int)index {
  return @"";
}


- (NSString *)sourceIdForMediaAtIndex:(int)index {
  return @"";
}


- (NSString *)sourceTypeForMediaAtIndex:(int)index {
  return @"";
}


- (BOOL)supportsImages {
  return YES;
}


- (BOOL)supportsVideo {
  return NO;
}


- (UIImage *)thumbnailAtIndex:(int)index {
  [NSException raise:@"Unsupported method" format:@"thumbnailAtIndex:"];
  return nil;
}


- (BOOL)thumbnailAtIndexIsReady:(int)index {
  [NSException raise:@"Unsupported method" format:@"thumbnailAtIndexIsReady:"];
  return NO;
}


- (NSString *)titleWithSupportForImages:(BOOL)supportsImages video:(BOOL)supportsVideo {
  return [self getTitle];
}


#pragma mark -


- (void)notifyInitialProgressChanged:(float)progress {
  for (int delegateIndex = 0; delegateIndex < numDelegates; delegateIndex++) {
    NSObject <CcMediaDataAvailabilityChangedDelegate> *delegate = delegates[delegateIndex];
    if ([delegate respondsToSelector:@selector(initialProgressChanged:progress:)]) {
      [delegate initialProgressChanged:self progress:progress];
    }
  }
}


- (void)notifyMediaDataAvailabilityChanged {
  for (int delegateIndex = 0; delegateIndex < numDelegates; delegateIndex++) {
    NSObject <CcMediaDataAvailabilityChangedDelegate> *delegate = delegates[delegateIndex];
    if ([delegate respondsToSelector:@selector(mediaDataAvailabilityChanged:)]) {
      [delegate mediaDataAvailabilityChanged:self];
    }
  }
}


- (void)notifyMediaProgressChanged:(float)progress mediaIndex:(int)mediaIndex {
  for (int delegateIndex = 0; delegateIndex < numDelegates; delegateIndex++) {
    NSObject <CcMediaDataAvailabilityChangedDelegate> *delegate = delegates[delegateIndex];
    if ([delegate respondsToSelector:@selector(mediaProgressChanged:mediaIndex:progress:)]) {
      [delegate mediaProgressChanged:self mediaIndex:mediaIndex progress:progress];
    }
  }
}


- (void)notifyThumbnailProgressChanged:(float)progress mediaIndex:(int)mediaIndex {
  for (int delegateIndex = 0; delegateIndex < numDelegates; delegateIndex++) {
    NSObject <CcMediaDataAvailabilityChangedDelegate> *delegate = delegates[delegateIndex];
    if ([delegate respondsToSelector:@selector(thumbnailProgressChanged:mediaIndex:progress:)]) {
      [delegate thumbnailProgressChanged:self mediaIndex:mediaIndex progress:progress];
    }
  }
}


@end
