#import <UIKit/UIKit.h>


@class CcHttpRequest;


@interface UIImageView (cliqcliq)

// This method should only be used when cancellation is not needed.
- (CcHttpRequest *)setImageWithUrl:(NSURL *)url;

@end
