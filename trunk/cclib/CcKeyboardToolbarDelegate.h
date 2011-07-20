#import <UIKit/UIKit.h>


@interface CcKeyboardToolbarDelegate : NSObject {
@protected
  UIScrollView *scrollView;
  UIToolbar *toolbar;
  UIView *view;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIView *view;

- (void)installKeyboardListeners;
- (void)uninstallKeyboardListeners;

@end
