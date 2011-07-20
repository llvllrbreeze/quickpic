#import "CcLogin.h"

#import "../CcAppDelegate.h"
#import "../CcConfiguration.h"
#import "../CcHttpRequest.h"
#import "../CcPlistHttpRequest.h"
#import "../CcSettings.h"
#import "../CcUiUtils.h"
#import "../CcUtils.h"
#import "../GANTracker.h"
#import "../NSDictionary+cliqcliq.h"
#import "../NSString+cliqcliq.h"
#import "../NSURL+cliqcliq.h"
#import "CcLoginSuccessDelegate.h"


@interface CcLogin ()
  @property (nonatomic, retain) CcPlistHttpRequest *request;
  - (void)onAccountCreateResponse:(NSHTTPURLResponse *)response
          data:(NSData *)data
          request:(CcHttpRequest *)theRequest;
  - (void)onLoginResponse:(NSHTTPURLResponse *)response
          data:(NSData *)data
          request:(CcHttpRequest *)theRequest;
  - (void)onLoginSuccess:(NSDictionary *)results;
  - (void)showWaitingOverlay:(BOOL)show;
  - (void)tryToCreateAccount;
  - (void)tryToLogin;
@end


@implementation CcLogin


@synthesize loginSuccessDelegate;
@synthesize request;


#pragma mark Initialization


- (void)viewDidLoad {
  self.title = @"Login / Signup";

  [CcUiUtils setupTextField:usernameText releaseOnDealloc:self.releaseOnDealloc];
  [CcUiUtils setupTextField:passwordText releaseOnDealloc:self.releaseOnDealloc];
  [CcUiUtils setupTextField:confirmPasswordText releaseOnDealloc:self.releaseOnDealloc];
  [CcUiUtils setupTextField:emailText releaseOnDealloc:self.releaseOnDealloc];
  [CcUiUtils setupTextField:tokenText releaseOnDealloc:self.releaseOnDealloc];

  scrollView.contentSize = CGSizeMake(320.0f, 416.0f);

  [self onTabSelected:loginTab];

  [super viewDidLoad];
}


#pragma mark Cleanup


- (void)dealloc {
  [self.request cancel];
  self.request = nil;

  [super dealloc];
}


#pragma mark UIViewController Methods


- (void)viewDidAppear:(BOOL)animated {
  NSError *error;
  [[GANTracker sharedTracker] trackPageview:@"/login" withError:&error];
}


#pragma mark UITextFieldDelegate


- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if (newAccountFields.hidden) {
    return;
  }

  if (textField == usernameText || textField == passwordText) {
    scrollView.contentOffset = CGPointMake(0.0f, 48.0f);
  } else if (textField == confirmPasswordText) {
    scrollView.contentOffset = CGPointMake(0.0f, 108.0f);
  } else if (textField == emailText) {
    scrollView.contentOffset = CGPointMake(0.0f, 152.0f);
  } else if (textField == tokenText) {
    scrollView.contentOffset = CGPointMake(0.0f, newAccountFields.hidden ? 48.0f : 152.0f);
  }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == usernameText) {
    [passwordText becomeFirstResponder];
  } else if (textField == passwordText) {
    if (newAccountFields.hidden) {
      [passwordText resignFirstResponder];
      [self onLoginClicked];
    } else {
      [confirmPasswordText becomeFirstResponder];
    }
  } else if (textField == confirmPasswordText) {
    [emailText becomeFirstResponder];
  } else if (textField == emailText) {
    [tokenText becomeFirstResponder];
  } else if (textField == tokenText) {
    [tokenText resignFirstResponder];
    [self onLoginClicked];
  }
  
  return YES;
}


#pragma mark -


- (IBAction)onDoneClicked {
  [usernameText becomeFirstResponder];
  [usernameText resignFirstResponder];

  scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
}


- (IBAction)onLoginClicked {
  [self onDoneClicked];
  
  if (!newAccountFields.hidden) {
    if (![confirmPasswordText.text isEqualToString:passwordText.text]) {
      [CcUtils alert:@"The passwords do not match.  Please re-enter them."];
      passwordText.text = @"";
      confirmPasswordText.text = @"";
      [passwordText becomeFirstResponder];
      return;
    }

    if ([confirmPasswordText.text isEqualToString:@""]) {
      [CcUtils alert:@"Empty passwords are not allowed."];
      return;
    }

    if ([usernameText.text isEqualToString:@""]) {
      [CcUtils alert:@"Please enter a username."];
      return;
    }

    if ([emailText.text isEqualToString:@""]) {
      [CcUtils alert:@"Please enter an email address."];
      return;
    }

    [self tryToCreateAccount];
  } else {
    [self tryToLogin];
  }
}


- (IBAction)onTabSelected:(UIButton *)sender {
  newAccountFields.hidden = sender != newTab;
  selectedTabBackground.frame = sender.frame;
  passwordText.returnKeyType = sender == newTab ? UIReturnKeyNext : UIReturnKeyGo;
}


- (UIScrollView *)scrollViewForKeyboardInteraction {
  return scrollView;
}


- (void)selectLoginTab {
  [self onTabSelected:loginTab];
}


- (void)selectSignupTab {
  [self onTabSelected:newTab];
}


- (void)setToken:(NSString *)token {
  tokenText.text = token;
}


#pragma mark Private


- (void)onAccountCreateResponse:(NSHTTPURLResponse *)response
        data:(NSData *)data
        request:(CcHttpRequest *)theRequest {
  NSError *error;
  [[GANTracker sharedTracker]
       trackEvent:@"auth"
       action:@"account-created"
       label:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]
       value:-1
       withError:&error];

  NSDictionary *results = [NSDictionary dictionaryWithPlistData:data];

  CcSettings *settings = [CcAppDelegate instance].settings;
  [settings setStringValue:[theRequest.data valueForKey:@"username"]
            forKey:@"authentication.username"];
  [settings setStringValue:[theRequest.data valueForKey:@"password"]
            forKey:@"authentication.password"];

  [self onLoginSuccess:results];
}


- (IBAction)onForgotLoginClicked {
    [[UIApplication sharedApplication]
         openURL:[[NSString stringWithFormat:@"%@/support/login/forgot/", kServerRootUrl] url]];
}


- (void)onLoginResponse:(NSHTTPURLResponse *)response
        data:(NSData *)data
        request:(CcHttpRequest *)theRequest {
  NSDictionary *results = [NSDictionary dictionaryWithPlistData:data];
  
  CcSettings *settings = [CcAppDelegate instance].settings;
  [settings setStringValue:[theRequest.data valueForKey:@"username"]
            forKey:@"authentication.username"];
  [settings setStringValue:[theRequest.data valueForKey:@"password"]
            forKey:@"authentication.password"];
  
  [self onLoginSuccess:results];
}


- (void)onLoginSuccess:(NSDictionary *)results {
  CcSettings *settings = [CcAppDelegate instance].settings;

  [settings setIntValue:1 forKey:@"authentication.logged-in"];

  NSDictionary *userData = [results valueForKey:@"user"];
  [settings setStringValue:[userData valueForKey:@"guid"] forKey:@"authentication.guid"];
  [settings setStringValue:[userData valueForKey:@"name"] forKey:@"authentication.name"];
  [settings setStringValue:[userData valueForKey:@"email"] forKey:@"authentication.email"];

  NSDictionary *avatarData = [userData valueForKey:@"avatar"];
  if (avatarData) {
    [settings setStringValue:[avatarData valueForKey:@"source_author"]
              forKey:@"avatar.source-author"];
    [settings setStringValue:[avatarData valueForKey:@"source_id"] forKey:@"avatar.source-id"];
    [settings setStringValue:[avatarData valueForKey:@"source_type"] forKey:@"avatar.source-type"];
  }

  [self.navigationController popViewControllerAnimated:YES];

  [self.loginSuccessDelegate loginSuccess];
}


- (void)onRequestComplete:(CcHttpRequest *)theRequest {
  [self showWaitingOverlay:NO];
  
  self.request = nil;
}


- (void)showWaitingOverlay:(BOOL)show {
  if (show) {
    waitingOverlay.frame = CGRectMake(0.0f, 20.0f, 320.0f, 460.0f);
    [[UIApplication sharedApplication].keyWindow addSubview:waitingOverlay];
    [waitingIndicator startAnimating];
  } else {
    [waitingIndicator stopAnimating];
    [waitingOverlay removeFromSuperview];
  }
}


- (void)tryToCreateAccount {
  NSURL *url = [NSURL URLWithStringWithFormat:@"%@/user/create/", kSecureServerRootUrl];
  NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                            kIphoneSecretKey, @"iphone_secret_key",
                            usernameText.text, @"username",
                            passwordText.text, @"password",
                            usernameText.text, @"screen_name",
                            emailText.text, @"email",
                            tokenText.text, @"token",
                            nil];
  self.request = [CcPlistHttpRequest requestUrl:url
                                     method:@"POST"
                                     data:data
                                     useStandardErrorHandling:YES];
  self.request.target = self;
  self.request.onSuccess = @selector(onAccountCreateResponse:data:request:);
  self.request.onRequestComplete = @selector(onRequestComplete:);
  [self.request send];

  [self showWaitingOverlay:YES];
}


- (void)tryToLogin {
  NSURL *url = [NSURL URLWithStringWithFormat:@"%@/user/login/", kSecureServerRootUrl];
  NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                            kIphoneSecretKey, @"iphone_secret_key",
                            usernameText.text, @"username",
                            passwordText.text, @"password",
                            tokenText.text, @"token",
                            nil];
  self.request = [CcPlistHttpRequest requestUrl:url
                                     method:@"POST"
                                     data:data
                                     useStandardErrorHandling:YES];
  self.request.target = self;
  self.request.onSuccess = @selector(onLoginResponse:data:request:);
  self.request.onRequestComplete = @selector(onRequestComplete:);
  [self.request send];

  [self showWaitingOverlay:YES];
}


@end
