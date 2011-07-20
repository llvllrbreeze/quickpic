#import "CcUtils.h"


CGRect CGRectWithBottomKeepTop(CGRect rect, float bottom) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, bottom - rect.origin.y);
}


CGRect CGRectWithCGPoint(CGRect rect, CGPoint point) {
  return CGRectMake(point.x, point.y, rect.size.width, rect.size.height);
}


CGRect CGRectWithCGSize(CGRect rect, CGSize size) {
  return CGRectMake(rect.origin.x, rect.origin.y, size.width, size.height);
}


CGRect CGRectWithHeight(CGRect rect, float height) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height);
}


CGRect CGRectWithPoint(CGRect rect, float x, float y) {
  return CGRectMake(x, y, rect.size.width, rect.size.height);
}


CGRect CGRectWithRightKeepLeft(CGRect rect, float right) {
  return CGRectMake(rect.origin.x, rect.origin.y, right - rect.origin.x, rect.size.height);
}


CGRect CGRectWithSize(CGRect rect, float width, float height) {
  return CGRectMake(rect.origin.x, rect.origin.y, width, height);
}


CGRect CGRectWithWidth(CGRect rect, float width) {
  return CGRectMake(rect.origin.x, rect.origin.y, width, rect.size.height);
}


CGRect CGRectWithX(CGRect rect, float x) {
  return CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height);
}


CGRect CGRectWithXKeepRight(CGRect rect, float x) {
  int originalRight = rect.origin.x + rect.size.width;
  int xDelta = x - rect.origin.x;
  return CGRectMake(x, rect.origin.y, originalRight - xDelta, rect.size.height);
}


CGRect CGRectWithY(CGRect rect, float y) {
  return CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height);
}


CGRect CGRectWithYKeepBottom(CGRect rect, float y) {
  int originalBottom = rect.origin.y + rect.size.height;
  int yDelta = y - rect.origin.y;
  return CGRectMake(rect.origin.x, y, rect.size.width, originalBottom - yDelta);
}


NSRange NSRangeMake(int location, int length) {
  NSRange range;
  range.location = location;
  range.length = length;
  return range;
}


@implementation CcUtils


+ (void)alert:(NSString *)message {
  [self alert:message title:@"cliqcliq"];
}


+ (void)alert:(NSString *)message title:(NSString *)title {
  UIAlertView *alert = [[[UIAlertView alloc]
      initWithTitle:title
      message:message
      delegate:nil
      cancelButtonTitle:@"Ok"
      otherButtonTitles:nil] autorelease];
  [alert show];
}


+ (NSString *)generateUuidString {
  CFUUIDRef uuid = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, uuid);
  NSString *output = [NSString stringWithString:(NSString *)string];
  CFRelease(string);
  CFRelease(uuid);

  return output;
}


+ (NSString *)getDocumentPath:(const NSString *)relativePath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentPath = [NSString stringWithFormat:@"%@/%@",
                                                      [paths objectAtIndex:0],
                                                      relativePath];
  return documentPath;
}


+ (UIView *)getKeyboardView {
    UIWindow *keyboardWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    NSArray* subviews = keyboardWindow.subviews;

    for (UIView *subview in subviews) {
        if ([[subview description] hasPrefix:@"<UIKeyboard"]) {
            return subview;
        }
    }
    
    return nil;
}


+ (NSString *)getResourcePath:(const NSString *)relativePath {
  return [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], relativePath];
}


@end
