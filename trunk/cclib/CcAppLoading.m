#import "CcAppLoading.h"

#import "CcAppDelegate.h"
#import "CcAppStateCodec.h"
#import "CcAppStateUtils.h"
#import "CcLocalCache.h"
#import "CcUtils.h"


static const int kCcAppLoadingNumSteps = 7;


@interface CcAppLoading ()
  - (void)cleanUpLocalCache;
  - (void)cleanUpSelf;
  - (void)initializeDatabase;
  - (void)loadDatabase;
  - (void)restoreInterfaceState_currentView;
  - (void)performNextStep;
@end


@implementation CcAppLoading


#pragma mark Initialization


- (void)viewDidLoad {
  [self performNextStep];
}


#pragma mark -


- (NSString *)databaseFilename {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}


- (UIViewController *)homeViewController {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}


- (BOOL)initializeDatabaseFromLegacyProduct:(NSString *)databasePath {
  return NO;
}


- (NSDictionary *)viewClassesDictionary {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}


#pragma mark Private


- (void)cleanUpLocalCache {
  [CcLocalCache cleanup];
  [self performNextStep];
}


- (void)cleanUpSelf {
  [self.view removeFromSuperview];
  [self release];
}


- (void)initializeCellFactory {
  [[CcAppDelegate instance] initializeCellFactory];
  [self performNextStep];
}


- (void)initializeDatabase {
  NSString *databasePath = [CcUtils getDocumentPath:[self databaseFilename]];
  
  // If the database file already exists, exit early.
  if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
    [self performNextStep];
    return;
  } else {
    NSString *installationDatabasePath = [CcUtils getResourcePath:[self databaseFilename]];
    NSError *error;
    if (![[NSFileManager defaultManager] copyItemAtPath:installationDatabasePath
                                         toPath:databasePath
                                         error:&error]) {
      NSAssert1(0, @"Unable to create writable database file: %@", [error localizedDescription]);
    }
  }

  // If successfully upgraded from a prior installation.
  if ([self initializeDatabaseFromLegacyProduct:databasePath]) {
    [self performNextStep];
    return;
  }

  [self performNextStep];
}


- (void)loadDatabase {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];
  
  NSString *databasePath = [CcUtils getDocumentPath:[self databaseFilename]];
  appDelegate.database = [CcDatabase databaseWithFile:databasePath];
  appDelegate.settings = [CcSettings settingsWithDatabase:appDelegate.database];
  
  [self performNextStep];
}


- (void)performNextStep {
  progressView.progress = MIN(1.0f, (float) step / (kCcAppLoadingNumSteps - 1));

  SEL stepSelectors[] = {@selector(initializeDatabase),
                         @selector(loadDatabase),
                         @selector(cleanUpLocalCache),
                         @selector(initializeCellFactory),
                         @selector(restoreInterfaceState_currentView),
                         @selector(returnControlToAppDelegate),
                         @selector(cleanUpSelf)};

  [self performSelector:stepSelectors[step] withObject:nil afterDelay:0.0f];
  step++;
}


- (void)restoreInterfaceState_currentView {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];
  CcSettings *settings = appDelegate.settings;

  int numStateLevels = [settings intValueForKey:@"state.num-levels" defaultValue:0];
  BOOL crashedDuringRestore = [settings intValueForKey:@"state.restore-in-progress"
                                        defaultValue:0];
  BOOL exitedNormally = [settings intValueForKey:@"state.exited-normally"
                                  defaultValue:0];

  [settings setIntValue:0 forKey:@"state.exited-normally"];
    
  if (!numStateLevels || crashedDuringRestore || !exitedNormally) {
    UIViewController *home = [self homeViewController];
    [appDelegate.navigationController pushViewController:home animated:NO];

    if (crashedDuringRestore || exitedNormally) {
      NSLog(@"Recovering from an inproper shutdown.  Not restoring previous state!");
    }
  } else {
    [settings setIntValue:1 forKey:@"state.restore-in-progress"];
    
    NSDictionary *values = nil;
    for (int level = 0; level < numStateLevels; level++) {
      NSString *key = [CcAppStateUtils stateKey:@"view-type" level:level];
      NSString *viewType = [settings stringValueForKey:key defaultValue:nil];
      
      NSDictionary *viewClasses = [self viewClassesDictionary];

      //instanceForRestoration
      Class viewClass = [viewClasses valueForKey:viewType];
      UIViewController <CcAppStateCodec> *viewController =
          [viewClass performSelector:@selector(instanceForRestoration)];
      values = [viewController restoreStateAtLevel:level values:values];
      [appDelegate.navigationController pushViewController:viewController animated:NO];
    }
  }

  [self performNextStep];
}


- (void)returnControlToAppDelegate {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];

  [appDelegate.settings setIntValue:0 forKey:@"state.restore-in-progress"];

  [appDelegate initializationComplete];
  [self performNextStep];
}


@end
