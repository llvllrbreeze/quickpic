#import <cclib/Cclib.h>


@interface SettingsPage : CcViewController {
@protected
  IBOutlet UISwitch *developerModeSwitch;
  IBOutlet UISwitch *statsSwitch;
  IBOutlet UISwitch *thumbnailSwitch;
}

- (IBAction)onAboutClicked;
- (IBAction)onDeveloperModeSwitchChanged;
- (IBAction)onStatsSwitchChanged;
- (IBAction)onThumbailSwitchChanged;

@end
