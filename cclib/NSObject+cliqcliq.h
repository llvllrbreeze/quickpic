#import <Foundation/Foundation.h>


@interface NSObject (cliqcliq)

- (void)performSelector:(SEL)aSelector
        withObject:(id)anObject
        withObject:(id)anotherObject
        afterDelay:(NSTimeInterval)delay;
- (id)performSelector:(SEL)aSelector
      withObject:(id)anObject
      withObject:(id)anotherObject
      withObject:(id)aThirdObject;
- (void)performSelector:(SEL)aSelector
        withObject:(id)anObject
        withObject:(id)anotherObject
        withObject:(id)aThirdObject
        afterDelay:(NSTimeInterval)delay;

@end
