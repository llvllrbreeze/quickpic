#import "UIViewController+cliqcliq.h"


@implementation UIViewController (cliqcliq)


- (void)forceViewToLoad {
  self.view.frame = self.view.frame; // Forcing selector to load.
}


@end
