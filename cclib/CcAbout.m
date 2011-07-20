#import "CcAbout.h"

#import "CcAppStateUtils.h"
#import "CcAppDelegate.h"


@interface CcAbout ()
  - (void)initializeIcon;
  - (void)initializeAppNameAndVersionLabels;
@end


@implementation CcAbout


#pragma mark Initialization


- (void)viewDidLoad {
  self.navigationItem.titleView = headerLogo;

  [self initializeIcon];
  [self initializeAppNameAndVersionLabels];
}


#pragma mark -


- (IBAction)onEmailLinkClicked {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:talk2us@cliqcliq.com"]];
}


- (IBAction)onWebsiteLinkClicked {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cliqcliq.com/"]];
}


#pragma mark Private


- (void)initializeIcon {
  NSBundle *bundle = [NSBundle mainBundle];
  
  NSString *iconFilename = (NSString *) [bundle objectForInfoDictionaryKey:@"CFBundleIconFile"];
  icon.image = [UIImage imageNamed:iconFilename];  
}


- (void)initializeAppNameAndVersionLabels {
  NSBundle *bundle = [NSBundle mainBundle];

  id appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
  id version = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];

  titleVersionHeaderLabel.text = [NSString stringWithFormat:@"%@ version %@", appName, version];
  titleVersionFooterLabel.text = [NSString stringWithFormat:@"%@ %@", appName, version];
}


@end
