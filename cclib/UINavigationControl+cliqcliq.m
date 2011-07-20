#import "UINavigationControl+cliqcliq.h"


@implementation UINavigationController (cliqcliq)


- (void)popToViewControllerOfKind:(Class)viewControllerClass animated:(BOOL)animated {
  UIViewController *viewController = nil;
  for (UIViewController *checkViewController in self.viewControllers) {
    if ([checkViewController isKindOfClass:viewControllerClass]) {
      viewController = checkViewController;
    }
  }
  
  if (viewController) {
    [self popToViewController:viewController animated:animated];
  } else {
    [self popToRootViewControllerAnimated:animated];
  }
}


@end
