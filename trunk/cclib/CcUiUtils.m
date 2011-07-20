#import "CcUiUtils.h"

#import "CcNineSlicedImage.h"


@implementation CcUiUtils


+ (UIView *)setupTextField:(UITextField *)textField
            releaseOnDealloc:(NSMutableSet *)releaseOnDealloc {
  UIView *textFieldParent = [textField superview];
  int indexOfTextField = [[[textField superview] subviews] indexOfObject:textField];

  CGRect frame = CGRectMake(textField.frame.origin.x - 4,
                            textField.frame.origin.y,
                            textField.frame.size.width + 8,
                            textField.frame.size.height);

  UIView *output = [[[UIView alloc] initWithFrame:frame] autorelease];
  [releaseOnDealloc addObject:output];

  CcNineSlicedImage *background = [[[CcNineSlicedImage alloc]
      initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
      image:[UIImage imageNamed:@"textInputBackground.png"]
      centerSlice:CGRectMake(8, 8, 43, 7)] autorelease];
  background.tag = 1;
  [output addSubview:background];

  [textField removeFromSuperview];

  textField.frame = CGRectMake(4, 0, frame.size.width - 8, frame.size.height);
  [output addSubview:textField];

  [textFieldParent insertSubview:output atIndex:indexOfTextField];

  return output;
}


+ (UIView *)setupTextView:(UITextView *)textView
            releaseOnDealloc:(NSMutableSet *)releaseOnDealloc {
  UIView *textViewParent = [textView superview];
  int indexOfTextView = [[[textView superview] subviews] indexOfObject:textView];

  CGRect frame = CGRectMake(textView.frame.origin.x,
                            textView.frame.origin.y,
                            textView.frame.size.width,
                            textView.frame.size.height);

  UIView *output = [[[UIView alloc] initWithFrame:frame] autorelease];
  [releaseOnDealloc addObject:output];

  CcNineSlicedImage *background = [[[CcNineSlicedImage alloc]
      initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)
      image:[UIImage imageNamed:@"textInputBackground.png"]
      centerSlice:CGRectMake(8, 8, 43, 7)] autorelease];
  [output addSubview:background];

  [textView removeFromSuperview];

  textView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
  [output addSubview:textView];

  [textViewParent insertSubview:output atIndex:indexOfTextView];

  return output;
}


+ (void)updateTextField:(UIView *)textFieldView showBackground:(BOOL)showBackground {
  CcNineSlicedImage *background = (CcNineSlicedImage *) [textFieldView viewWithTag:1];
  background.hidden = !showBackground;
}


@end
