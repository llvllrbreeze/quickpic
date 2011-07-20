#import <UIKit/UIKit.h>


@class CcMaskedImage;


@interface CcAvatarButtonIcon : UIView {
@protected
  UIImageView *highlight;
  CcMaskedImage *maskedAvatar;
  UIImageView *shadow;
}

- (void)setAvatar:(UIImage *)image;

@end
