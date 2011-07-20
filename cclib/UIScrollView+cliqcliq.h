#import <Foundation/Foundation.h>


@interface UIScrollView (cliqcliq)

- (void)scrollRectDictionaryToVisible:(NSDictionary *)rectDictionary animated:(BOOL)animated;
- (void)scrollToTop:(BOOL)animate;

@end
