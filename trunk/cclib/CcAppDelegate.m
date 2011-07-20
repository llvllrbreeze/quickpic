#import "CcAppDelegate.h"

#import <stdlib.h>
#import <time.h>

#import "CcAbout.h"
#import "CcAppStateUtils.h"
#import "CcCellFactory.h"
#import "CcUtils.h"
#import "GANTracker.h"


static CcAppDelegate *ccAppDelegateInstance;


@interface CcAppDelegate ()
  - (void)showFeedbackAlertWhenAppropriate;
@end


@implementation CcAppDelegate

@synthesize cellFactory;
@synthesize database;
@synthesize navigationController;
@synthesize settings;
@synthesize window;


#pragma mark Initialization


+ (void)init:(CcAppDelegate *)theAppDelegate {
  ccAppDelegateInstance = theAppDelegate;
}


- (void)initializeApplication {
  [self doesNotRecognizeSelector:_cmd];
}


- (void)initializeCellFactory {
  self.cellFactory = [[CcCellFactory alloc] initWithNib:@"CcStandardCellViews"];
}


#pragma mark Cleanup


- (void)dealloc {
  [[GANTracker sharedTracker] stopTracker];
  
  self.cellFactory = nil;
  self.database = nil;
  self.settings = nil;
  
  [super dealloc];
}


#pragma mark UIApplicationDelegate Methods


- (void)applicationDidFinishLaunching:(UIApplication *)application {
  srandom(time(NULL));

  [CcAppDelegate init:self];

  [window makeKeyAndVisible];

  [self initializeApplication];
}


- (void)applicationWillTerminate:(UIApplication *)application {
  [CcAppStateUtils saveApplicationState];

  [self.settings setIntValue:1 forKey:@"state.exited-normally"];
}


#pragma mark -


- (void)initializationComplete {
  [self.window addSubview:self.navigationController.view];

  [self showFeedbackAlertWhenAppropriate];
}


+ (CcAppDelegate *)instance {
  return ccAppDelegateInstance;
}


- (void)showAbout {
  CcAbout *about = [[[CcAbout alloc] init] autorelease];
  [self.navigationController pushViewController:about animated:YES];
}


#pragma mark Private


- (void)showFeedbackAlertWhenAppropriate {
  int numUses = [self.settings intValueForKey:@"application.use-count" defaultValue:0];
  numUses++;
  if (numUses == 5) {
    [CcUtils alert:@"Now that you've had some time to try out this app, we'd really love your feedback.  Please, send us an email or write a review when you get a chance."];
  } else if (numUses == 20) {
    [CcUtils alert:@"If you haven't had a chance to write a review yet, please take a moment when you can."];
  } else if (numUses == 50) {
    [CcUtils alert:@"As a frequent user of this application you've probably got some things you like and dislike about it.  Please, shoot us an email when you get a chance and let us know about your experiences."];
  }
  [self.settings setIntValue:numUses forKey:@"application.use-count"];
}


@end
