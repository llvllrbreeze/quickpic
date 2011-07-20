#import "UIScrollView+cliqcliq.h"


@implementation UIScrollView (cliqcliq)


- (void)scrollRectDictionaryToVisible:(NSDictionary *)rectDictionary animated:(BOOL)animated {
  CGRect rect;
  CGRectMakeWithDictionaryRepresentation((CFDictionaryRef) rectDictionary, &rect);

  rect.size.height = self.frame.size.height;

  if (rect.origin.y + rect.size.height > self.contentSize.height) {
    rect.origin.y = MAX(0.0f, self.contentSize.height - rect.size.height);
  }

  [self scrollRectToVisible:rect animated:animated];
}


- (void)scrollToTop:(BOOL)animate {
  [self scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:animate];
}


@end
