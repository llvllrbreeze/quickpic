#import "SettingsPage.h"

#import "Constants.h"


@implementation SettingsPage


#pragma mark Initialization


- (void)viewDidLoad {
  self.title = @"Settings";

  CcSettings *settings = [CcAppDelegate instance].settings;

  BOOL allowStats = [settings intValueForKey:@"pref.allow-stats" defaultValue:1];
  statsSwitch.on = allowStats;

  BOOL developerMode = [settings intValueForKey:@"pref.developer-mode" defaultValue:0];
  developerModeSwitch.on = developerMode;

  BOOL thumbnailPhotos = [settings intValueForKey:@"pref.thumbnail-photos" defaultValue:1];
  thumbnailSwitch.on = thumbnailPhotos;
}


#pragma mark UIViewController Methods


- (void)viewDidAppear:(BOOL)animated {
  NSError *error;
  [[GANTracker sharedTracker] trackPageview:@"/settings" withError:&error];
}


#pragma mark -


- (IBAction)onAboutClicked {
  [[CcAppDelegate instance] showAbout];
}


- (IBAction)onDeveloperModeSwitchChanged {
  CcSettings *settings = [CcAppDelegate instance].settings;
  [settings setIntValue:developerModeSwitch.on forKey:@"pref.developer-mode"];
}


- (IBAction)onStatsSwitchChanged {
  CcSettings *settings = [CcAppDelegate instance].settings;
  [settings setIntValue:statsSwitch.on forKey:@"pref.allow-stats"];

  if (statsSwitch.on) {
    [[GANTracker sharedTracker] startTrackerWithAccountID:GA_ACCOUNT_ID
                                dispatchPeriod:10
                                delegate:nil];
  } else {
    [[GANTracker sharedTracker] stopTracker];
  }
}


- (IBAction)onThumbailSwitchChanged {
  CcSettings *settings = [CcAppDelegate instance].settings;
  [settings setIntValue:thumbnailSwitch.on forKey:@"pref.thumbnail-photos"];
}


@end
