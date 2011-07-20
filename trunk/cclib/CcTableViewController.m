#import "CcTableViewController.h"


@implementation CcTableViewController


#pragma mark Cleanup


- (void)dealloc {
  [releaseOnDealloc release];

  [super dealloc];
}


#pragma mark -


- (NSMutableSet *)releaseOnDealloc {
  if (releaseOnDealloc) {
    return releaseOnDealloc;
  }
  
  releaseOnDealloc = [[NSMutableSet alloc] init]; // Not auto-releasing, cleaning up in dealloc.
  return releaseOnDealloc;
}


@end
