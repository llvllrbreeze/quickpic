#import <UIKit/UIKit.h>


@interface CcUiUtils : NSObject {

}

+ (UIView *)setupTextField:(UITextField *)textField
            releaseOnDealloc:(NSMutableSet *)releaseOnDealloc;
+ (UIView *)setupTextView:(UITextView *)textView
            releaseOnDealloc:(NSMutableSet *)releaseOnDealloc;
+ (void)updateTextField:(UIView *)textFieldView showBackground:(BOOL)showBackground;

@end
