#import <UIKit/UIKit.h>


@class CcKeyboardToolbarDelegate;


@interface CcViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate> {
@protected
  IBOutlet UIToolbar *keyboardToolbar;
  CcKeyboardToolbarDelegate *keyboardToolbarDelegate;
  NSMutableSet *releaseOnDealloc;
}

@property (nonatomic, readonly, retain) NSMutableSet *releaseOnDealloc;
@property (nonatomic, readonly) UIScrollView *scrollViewForKeyboardInteraction;

@end
