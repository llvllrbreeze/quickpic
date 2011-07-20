#import <UIKit/UIKit.h>

#import "CcAppStateCodec.h"


/*!
 * @class CcAbout
 * The standard cliqcliq about view controller.  About views are largely static content but do
 * dynamically set the application name, version number, and icon based on the info.plist file.  As
 * time goes by, the credits section should be manually updated as necessary.  Also, the copyright
 * year should be updated as necessary.
 */
@interface CcAbout : UIViewController {
@private
  IBOutlet UIImageView *headerLogo;
  IBOutlet UIImageView *icon;
  IBOutlet UILabel *titleVersionHeaderLabel;
  IBOutlet UILabel *titleVersionFooterLabel;
}

- (IBAction)onEmailLinkClicked;
- (IBAction)onWebsiteLinkClicked;

@end
