#import <UIKit/UIKit.h>

#import "../CcViewController.h"


@class CcPlistHttpRequest;
@protocol CcLoginSuccessDelegate;


@interface CcLogin : CcViewController {
@protected
  IBOutlet UITextField *confirmPasswordText;
  IBOutlet UITextField *emailText;
  NSObject <CcLoginSuccessDelegate> *loginSuccessDelegate;
  IBOutlet UIButton *loginTab;
  IBOutlet UIButton *newTab;
  IBOutlet UIView *newAccountFields;
  IBOutlet UITextField *passwordText;
  IBOutlet UITextField *screenNameText;
  CcPlistHttpRequest *request;
  IBOutlet UIScrollView *scrollView;
  IBOutlet UIImageView *selectedTabBackground;
  IBOutlet UITextField *tokenText;
  IBOutlet UITextField *usernameText;
  IBOutlet UIActivityIndicatorView *waitingIndicator;
  IBOutlet UIView *waitingOverlay;
}

@property (nonatomic, assign) NSObject <CcLoginSuccessDelegate> *loginSuccessDelegate;

- (IBAction)onDoneClicked;
- (IBAction)onForgotLoginClicked;
- (IBAction)onLoginClicked;
- (IBAction)onTabSelected:(UIButton *)sender;
- (void)selectLoginTab;
- (void)selectSignupTab;
- (void)setToken:(NSString *)token;

@end
