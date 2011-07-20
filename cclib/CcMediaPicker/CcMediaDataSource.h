@class CcMedia;
@protocol CcMediaDataAvailabilityChangedDelegate;


@protocol CcMediaDataSource

- (void)addDelegate:(NSObject <CcMediaDataAvailabilityChangedDelegate> *)delegate;
- (void)cancel;
- (NSString *)getLastError;
- (NSString *)getTitle;
- (BOOL)hadError;
- (BOOL)isReady;
- (BOOL)isSearchable;
- (CcMedia *)mediaAtIndex:(int)index;
- (BOOL)mediaAtIndexIsReady:(int)index;
- (int)mediaCount;
- (int)mediaIdForMediaAtIndex:(int)index;
- (void)removeDelegate:(NSObject <CcMediaDataAvailabilityChangedDelegate> *)delegate;
- (BOOL)requestMediaAtIndex:(int)index;
- (BOOL)requestThumbnailAtIndex:(int)index;
- (void)setSearchQuery:(NSString *)query;
- (NSString *)sourceAuthorForMediaAtIndex:(int)index;
- (NSString *)sourceIdForMediaAtIndex:(int)index;
- (NSString *)sourceTypeForMediaAtIndex:(int)index;
- (UIImage *)thumbnailAtIndex:(int)index;
- (BOOL)thumbnailAtIndexIsReady:(int)index;

@end
