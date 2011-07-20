#import "NSObject+cliqcliq.h"


@interface NSObject ()
  - (void)handlePerformMultiParamSelectorAfterDelay:(NSArray *)params;
@end


@implementation NSObject (cliqcliq)


- (void)handlePerformMultiParamSelectorAfterDelay:(NSArray *)params {
  SEL aSelector = NSSelectorFromString([params objectAtIndex:0]);
  int numParams = [params count] - 1;

  if (numParams == 1) {
    [self performSelector:aSelector withObject:[params objectAtIndex:1]];
  } else if (numParams == 2) {
    [self performSelector:aSelector
          withObject:[params objectAtIndex:1]
          withObject:[params objectAtIndex:2]];
  } else if (numParams == 3) {
    [self performSelector:aSelector
          withObject:[params objectAtIndex:1]
          withObject:[params objectAtIndex:2]
          withObject:[params objectAtIndex:3]];
  }
}


- (void)performSelector:(SEL)aSelector
        withObject:(id)anObject
        withObject:(id)anotherObject
        afterDelay:(NSTimeInterval)delay {
  [self performSelector:@selector(handlePerformMultiParamSelectorAfterDelay:)
        withObject:[NSArray arrayWithObjects:NSStringFromSelector(aSelector),
                                             anObject,
                                             anotherObject,
                                             nil]
        afterDelay:delay];
}


- (id)performSelector:(SEL)aSelector
      withObject:(id)anObject
      withObject:(id)anotherObject
      withObject:(id)aThirdObject {
  return objc_msgSend(self, aSelector, anObject, anotherObject, aThirdObject);
}


- (void)performSelector:(SEL)aSelector
        withObject:(id)anObject
        withObject:(id)anotherObject
        withObject:(id)aThirdObject
        afterDelay:(NSTimeInterval)delay {
  [self performSelector:@selector(handlePerformMultiParamSelectorAfterDelay:)
        withObject:[NSArray arrayWithObjects:NSStringFromSelector(aSelector),
                                             anObject,
                                             anotherObject,
                                             aThirdObject,
                                             nil]
        afterDelay:delay];
}


@end
