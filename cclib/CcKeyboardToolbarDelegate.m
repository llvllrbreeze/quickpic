#import "CcKeyboardToolbarDelegate.h"

#import "CcConstants.h"
#import "CcUtils.h"


@implementation CcKeyboardToolbarDelegate


@synthesize scrollView;
@synthesize toolbar;
@synthesize view;


#pragma mark Cleanup


- (void)dealloc {
  self.scrollView = nil;
  self.toolbar = nil;
  self.view = nil;

  [super dealloc];
}


#pragma mark -


- (void)installKeyboardListeners {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
      selector:@selector(keyboardDidHide:)
      name:UIKeyboardDidHideNotification
      object:nil];
  [nc addObserver:self
      selector:@selector(keyboardDidShow:)
      name:UIKeyboardDidShowNotification
      object:nil];
  [nc addObserver:self
      selector:@selector(keyboardWillHide:)
      name:UIKeyboardWillHideNotification
      object:nil];
  [nc addObserver:self
      selector:@selector(keyboardWillShow:)
      name:UIKeyboardWillShowNotification
      object:nil];
}


- (void)uninstallKeyboardListeners {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self
      name:UIKeyboardDidHideNotification
      object:nil];
  [nc removeObserver:self
      name:UIKeyboardDidShowNotification
      object:nil];
  [nc removeObserver:self
      name:UIKeyboardWillHideNotification
      object:nil];
  [nc removeObserver:self
      name:UIKeyboardWillShowNotification
      object:nil];
}


#pragma mark Private


- (void)keyboardDidHide:(NSNotification *)note {
  [self.toolbar removeFromSuperview];
}


- (void)keyboardDidShow:(NSNotification *)note {
  self.scrollView.frame = CGRectWithHeight(self.scrollView.frame,
                                           kAvailableHeightForViewWithKeyboardAndToolbarVisible);

  [self.toolbar removeFromSuperview];
  self.toolbar.frame = CGRectWithY(self.toolbar.frame,
                                   kAvailableHeightForViewWithKeyboardAndToolbarVisible);
  [self.view addSubview:self.toolbar];
}


- (void)keyboardWillHide:(NSNotification *)note {
  [self.toolbar removeFromSuperview];

  CGPoint currentOffset = self.scrollView.contentOffset;
  self.scrollView.frame = CGRectWithHeight(self.scrollView.frame, 416.0f);
  self.scrollView.contentOffset = currentOffset;
}


- (void)keyboardWillShow:(NSNotification *)note {
  [self.toolbar removeFromSuperview];
  self.toolbar.frame = CGRectWithY(self.toolbar.frame, -44.0f);

  UIView *keyboard = [CcUtils getKeyboardView];
  [keyboard addSubview:self.toolbar];
}


@end
