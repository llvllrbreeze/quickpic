#import <UIKit/UIKit.h>


@class CcHttpRequest;


@interface UIImage (cliqcliq)

+ (UIImage *)correctOrientation:(UIImage *)image;
+ (UIImage *)flipVertically:(UIImage *)image;
+ (CcHttpRequest *)loadImageWithUrl:(NSURL *)url target:(NSObject *)target set:(SEL)setSelector;
+ (UIImage *)posterImageForMovieWithFileUrl:(NSURL *)url;
- (UIImage *)thumbnail:(CGSize)size;
- (UIImage *)thumbnail:(CGSize)size zoomAndCrop:(BOOL)zoomAndCrop;

@end
