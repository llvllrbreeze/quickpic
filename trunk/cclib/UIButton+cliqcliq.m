#import "UIButton+cliqcliq.h"


@implementation UIButton (cliqcliq)


- (void)setBackgroundImage:(UIImage *)image {
  [self setBackgroundImage:image forState:UIControlStateNormal];
  [self setBackgroundImage:image forState:UIControlStateHighlighted];
  [self setBackgroundImage:image forState:UIControlStateSelected];
  [self setBackgroundImage:image forState:UIControlStateDisabled];
  [self setBackgroundImage:image forState:UIControlStateApplication];
}


- (void)setImage:(UIImage *)image {
  [self setImage:image forState:UIControlStateNormal];
  [self setImage:image forState:UIControlStateHighlighted];
  [self setImage:image forState:UIControlStateSelected];
  [self setImage:image forState:UIControlStateDisabled];
  [self setImage:image forState:UIControlStateApplication];
}


- (void)setTitle:(NSString *)title {
  [self setTitle:title forState:UIControlStateNormal];
  [self setTitle:title forState:UIControlStateHighlighted];
  [self setTitle:title forState:UIControlStateSelected];
  [self setTitle:title forState:UIControlStateDisabled];
  [self setTitle:title forState:UIControlStateApplication];
}


- (void)setTitleColor:(UIColor *)color {
  [self setTitleColor:color forState:UIControlStateNormal];
  [self setTitleColor:color forState:UIControlStateHighlighted];
  [self setTitleColor:color forState:UIControlStateSelected];
  [self setTitleColor:color forState:UIControlStateDisabled];
  [self setTitleColor:color forState:UIControlStateApplication];
}


- (void)setTitleShadowColor:(UIColor *)color {
  [self setTitleShadowColor:color forState:UIControlStateNormal];
  [self setTitleShadowColor:color forState:UIControlStateHighlighted];
  [self setTitleShadowColor:color forState:UIControlStateSelected];
  [self setTitleShadowColor:color forState:UIControlStateDisabled];
  [self setTitleShadowColor:color forState:UIControlStateApplication];
}


@end
