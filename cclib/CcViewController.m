#import "CcViewController.h"

#import "CcKeyboardToolbarDelegate.h"


@implementation CcViewController


#pragma mark Initialization


- (void)viewDidLoad {
  if (self.scrollViewForKeyboardInteraction) {
    keyboardToolbarDelegate = [[CcKeyboardToolbarDelegate alloc] init]; // Not auto-releasing, cleaning up in dealloc.
    keyboardToolbarDelegate.toolbar = keyboardToolbar;
    keyboardToolbarDelegate.scrollView = self.scrollViewForKeyboardInteraction;
    keyboardToolbarDelegate.view = self.view;
  }

  [super viewDidLoad];
}


#pragma mark Cleanup


- (void)dealloc {
  [keyboardToolbarDelegate release];
  keyboardToolbarDelegate = nil;

  [releaseOnDealloc release];

  [super dealloc];
}


#pragma mark UIViewController Methods


- (void)viewDidAppear:(BOOL)animated {
  [keyboardToolbarDelegate installKeyboardListeners];
}


- (void)viewWillDisappear:(BOOL)animated {
  [keyboardToolbarDelegate uninstallKeyboardListeners];
}


#pragma mark -


- (NSMutableSet *)releaseOnDealloc {
  if (releaseOnDealloc) {
    return releaseOnDealloc;
  }
  
  releaseOnDealloc = [[NSMutableSet alloc] init]; // Not auto-releasing, cleaning up in dealloc.
  return releaseOnDealloc;
}


- (UIScrollView *)scrollViewForKeyboardInteraction {
  return nil;
}


@end
