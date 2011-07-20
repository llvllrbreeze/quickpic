#import <UIKit/UIKit.h>

#import "../CcMediaPicker/CcMediaPickerLib.h"
#import "../CcViewController.h"


@class CcHttpRequest;


@interface CcUserSettings : CcViewController <CcMediaPickerDelegate> {
@protected
  IBOutlet UIImageView *avatar;
  IBOutlet UITextField *confirmPasswordText;
  IBOutlet UITextField *emailText;
  CcHttpRequest *imageRequest;
  IBOutlet UITextField *passwordText;
  IBOutlet UIButton *photoCreditButton;
  IBOutlet UITextField *screenNameText;
  CcHttpRequest *request;
  IBOutlet UIBarButtonItem *saveButton;
  IBOutlet UIScrollView *scrollView;
  IBOutlet UIBarButtonItem *signOutButton;
  IBOutlet UIProgressView *uploadProgressBar;
  IBOutlet UILabel *usernameLabel;
}

- (IBAction)onDoneClicked;
- (IBAction)onPhotoCreditClicked;
- (IBAction)onSaveClicked;
- (IBAction)onSelectAvatarClicked;
- (IBAction)onSignoutClicked;
- (IBAction)onTextChanged;

@end
