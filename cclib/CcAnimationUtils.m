#import "CcAnimationUtils.h"

#import <QuartzCore/QuartzCore.h>


@implementation CcAnimationUtils


+ (void)setupAnimationWithStyle:(NSString *)style forView:(UIView *)view {
  if ([style hasPrefix:@"push"] || [style hasPrefix:@"reveal"]) {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    [transition setType:[style hasPrefix:@"push"] ? kCATransitionPush : kCATransitionReveal];
    [transition setSubtype:[style hasSuffix:@"right"] ? kCATransitionFromRight :
                           [style hasSuffix:@"left"] ? kCATransitionFromLeft :
                           [style hasSuffix:@"bottom"] ? kCATransitionFromBottom :
                                                         kCATransitionFromTop];
    [view.layer addAnimation:transition forKey:@"Transition"];
  } else if ([style isEqualToString:@"cross-fade"]) {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    [transition setType:kCATransitionFade];
    [view.layer addAnimation:transition forKey:@"Transition"];
  } else if ([style hasPrefix:@"fade"]) {
    [UIView beginAnimations:@"fade" context:nil];
    [UIView setAnimationDuration:0.25];
    view.alpha = [style hasSuffix:@"in"] ? 1.0 :
                 [style hasSuffix:@"half"] ? 0.5 : 0.0;
    [UIView commitAnimations];
  } else {
    [UIView beginAnimations:@"flip" context:nil];
    [UIView setAnimationTransition:[style hasSuffix:@"right"] ?
                UIViewAnimationTransitionFlipFromRight :
                UIViewAnimationTransitionFlipFromLeft
            forView:view
            cache:YES];
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];
  }
}


@end
