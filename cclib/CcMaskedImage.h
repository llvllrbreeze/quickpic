#import <UIKit/UIKit.h>


@interface CcMaskedImage : UIView {
  UIImage *image;
  CGImageRef mask;
}

- (id)initWithImage:(UIImage *)theImage mask:(UIImage *)theMask;

@end
