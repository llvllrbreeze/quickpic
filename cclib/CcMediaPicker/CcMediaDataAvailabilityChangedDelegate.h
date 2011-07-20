@protocol CcMediaDataAvailabilityChangedDelegate

@optional
- (void)mediaDataAvailabilityChanged:(id)target;
- (void)mediaProgressChanged:(id)target mediaIndex:(int)index progress:(float)progress;
- (void)initialProgressChanged:(id)target progress:(float)progress;
- (void)thumbnailProgressChanged:(id)target mediaIndex:(int)index progress:(float)progress;

@end
