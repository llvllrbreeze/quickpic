#import "CcMediaDataSource.h"

@protocol CcMediaDataAvailabilityChangedDelegate;

@interface CcMediaDataSourceBase : NSObject <CcMediaDataSource> {
@private
  NSObject <CcMediaDataAvailabilityChangedDelegate> **delegates; // Using a standard array so there's no retaining.
  int numDelegates;
}

- (void)notifyMediaDataAvailabilityChanged;
- (void)notifyMediaProgressChanged:(float)progress mediaIndex:(int)mediaIndex;
- (void)notifyInitialProgressChanged:(float)progress;
- (void)notifyThumbnailProgressChanged:(float)progress mediaIndex:(int)mediaIndex;

@end
