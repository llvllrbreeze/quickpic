#import "UIView+cliqcliq.h"


@implementation UIView (cliqcliq)


- (void)removeAllSubviews {
  for (UIView *subview in [self subviews]) {
    [subview removeFromSuperview];
  }
}


- (void)replaceSubview:(UIView *)subview with:(UIView *)newSubview {
  [self insertSubview:newSubview belowSubview:subview];
  [subview removeFromSuperview];
}


@end
