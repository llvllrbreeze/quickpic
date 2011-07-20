#import "UITableView+cliqcliq.h"

#import "CcConstants.h"


@implementation UITableView (cliqcliq)


- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
        atScrollPosition:(UITableViewScrollPosition)scrollPosition
        animated:(BOOL)animated
        keyboardAndToolbarVisible:(BOOL)keyboardAndToolbarVisible {
  if (!keyboardAndToolbarVisible) {
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
  } else {
    CGRect scrollToRect = [self rectForRowAtIndexPath:indexPath];
    CGFloat extraOffset = 0.0f;
    
    CGFloat extraHeight = scrollToRect.size.height - 
                              kAvailableHeightForViewWithKeyboardAndToolbarVisible;
    
    if (scrollPosition == UITableViewScrollPositionBottom) {
      extraOffset = MAX(0.0f, extraHeight);
    } else if (scrollPosition == UITableViewScrollPositionMiddle) {
      extraOffset = MAX(0.0f, (CGFloat) round(extraHeight / 2.0f));
    }
    
    [self setContentOffset:CGPointMake(0.0, scrollToRect.origin.y + extraOffset) animated:animated];
  }
}


@end
