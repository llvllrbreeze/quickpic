#import <Foundation/Foundation.h>

#import "CcHttpRequest.h"


CGRect CGRectWithBottomKeepTop(CGRect rect, float bottom);
CGRect CGRectWithCGPoint(CGRect rect, CGPoint point);
CGRect CGRectWithCGSize(CGRect rect, CGSize size);
CGRect CGRectWithHeight(CGRect rect, float height);
CGRect CGRectWithPoint(CGRect rect, float x, float y);
CGRect CGRectWithRightKeepLeft(CGRect rect, float right);
CGRect CGRectWithSize(CGRect rect, float width, float height);
CGRect CGRectWithWidth(CGRect rect, float width);
CGRect CGRectWithX(CGRect rect, float x);
CGRect CGRectWithXKeepRight(CGRect rect, float x);
CGRect CGRectWithY(CGRect rect, float y);
CGRect CGRectWithYKeepBottom(CGRect rect, float y);

NSRange NSRangeMake(int location, int length);


@interface CcUtils : NSObject {
}

+ (void)alert:(NSString *)message;
+ (void)alert:(NSString *)message title:(NSString *)title;
+ (NSString *)generateUuidString;
+ (NSString *)getDocumentPath:(const NSString *)relativePath;
+ (UIView *)getKeyboardView;
+ (NSString *)getResourcePath:(const NSString *)relativePath;

@end
