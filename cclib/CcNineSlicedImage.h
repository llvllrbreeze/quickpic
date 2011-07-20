#import <UIKit/UIKit.h>


@interface CcNineSlicedImage : UIView {
  @private
    CGRect centerSlice;
    UIImage *image;
    NSMutableArray *sliceImages;
}

@property (nonatomic, retain) UIImage *image;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)sliceableImage centerSlice:(CGRect)slice;

@end
