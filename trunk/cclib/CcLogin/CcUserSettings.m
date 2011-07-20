#import "CcUserSettings.h"

#import "../CcAppDelegate.h"
#import "../CcConfiguration.h"
#import "../CcConstants.h"
#import "../CcHttpRequest.h"
#import "../CcLocalCache.h"
#import "../CcMediaPicker/CcMediaPickerLib.h"
#import "../CcPlistHttpRequest.h"
#import "../CcSettings.h"
#import "../CcUiUtils.h"
#import "../CcUtils.h"
#import "../GANTracker.h"
#import "../NSURL+cliqcliq.h"
#import "../UIButton+cliqcliq.h"
#import "../UIImageView+cliqcliq.h"


@interface CcUserSettings ()
  @property (nonatomic, retain) CcHttpRequest *imageRequest;
  @property (nonatomic, retain) CcHttpRequest *request;
  - (void)onAccountUpdateResponse:(NSHTTPURLResponse *)response
          data:(NSData *)data
          request:(CcHttpRequest *)theRequest;
  - (void)onNetworkError:(NSError *)error request:(CcHttpRequest *)theRequest;
  - (void)tryToUpdateAccount;
  - (void)updatePhotoCreditButton;
@end


@implementation CcUserSettings


@synthesize imageRequest;
@synthesize request;


#pragma mark Initialization


- (void)viewDidLoad {
  CcSettings *settings = [CcAppDelegate instance].settings;

  self.title = @"User Settings";
  self.navigationItem.rightBarButtonItem = signOutButton;

  [CcUiUtils setupTextField:passwordText releaseOnDealloc:self.releaseOnDealloc];
  [CcUiUtils setupTextField:confirmPasswordText releaseOnDealloc:self.releaseOnDealloc];
  [CcUiUtils setupTextField:screenNameText releaseOnDealloc:self.releaseOnDealloc];
  [CcUiUtils setupTextField:emailText releaseOnDealloc:self.releaseOnDealloc];

  scrollView.contentSize = CGSizeMake(320.0f, 416.0f);

  usernameLabel.text = [settings stringValueForKey:@"authentication.username" defaultValue:@""];
  passwordText.text = [settings stringValueForKey:@"authentication.password" defaultValue:@""];
  confirmPasswordText.text = @"";
  screenNameText.text = [settings stringValueForKey:@"authentication.name" defaultValue:@""];
  emailText.text = [settings stringValueForKey:@"authentication.email" defaultValue:@""];
  
  NSString *userGuid = [settings stringValueForKey:@"authentication.guid" defaultValue:nil];

  self.imageRequest = [avatar setImageWithUrl:[NSURL avatarUrlForUserWithGuid:userGuid large:YES]];

  [self onTextChanged];

  [self updatePhotoCreditButton];

  [super viewDidLoad];
}


#pragma mark Cleanup


- (void)dealloc {
  [self.imageRequest cancel];
  self.imageRequest = nil;

  [self.request cancel];
  self.request = nil;

  [super dealloc];
}


#pragma mark CcMediaPickerControllerDelegate


- (void)mediaPickerController:(CcMediaPicker *)picker
        didFinishPickingMedia:(CcMedia *)media
        mediaId:(int)mediaId {
  [self.navigationController popToViewController:self animated:YES];

  avatar.image = media.image;
  
  CcSettings *settings = [CcAppDelegate instance].settings;
  NSString *userGuid = [settings stringValueForKey:@"authentication.guid" defaultValue:nil];
  
  NSURL *url = [NSURL URLWithStringWithFormat:@"%@/user/%@/avatar/upload/",
                                              kServerRootUrl,
                                              userGuid];
  NSDictionary *file = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"image_file", @"name",
                                         @"profile.jpg", @"filename",
                                         UIImagePNGRepresentation(media.image), @"data",
                                         nil];
  NSArray *files = [NSArray arrayWithObject:file];
  NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                            kIphoneKey, @"iphone_key",
                            media.sourceAuthor, @"source_author",
                            media.sourceId, @"source_id",
                            media.sourceType, @"source_type",
                            files, @"__files__",
                            nil];
  [self.imageRequest cancel]; // Cancels any prior requests.
  self.imageRequest = [CcPlistHttpRequest requestUrl:url
                                          method:@"POST(multipart/form-data)"
                                          data:data
                                          useStandardErrorHandling:YES];
  self.imageRequest.target = self;
  self.imageRequest.onError = @selector(onNetworkError:request:);
  self.imageRequest.onSuccess = @selector(onImageUploadResponse:data:request:);
  self.imageRequest.onProgress = @selector(onImageUploadData:progress:request:);
  [self.imageRequest send];

  uploadProgressBar.progress = 0.0f;
  uploadProgressBar.hidden = NO;

  [settings setStringValue:media.sourceAuthor forKey:@"avatar.source-author"];
  [settings setStringValue:media.sourceId forKey:@"avatar.source-id"];
  [settings setStringValue:media.sourceType forKey:@"avatar.source-type"];
  [self updatePhotoCreditButton];
}


#pragma mark UITextFieldDelegate


- (void)textFieldDidBeginEditing:(UITextField *)textField {
  // TODO(westphal): Animate and use same method as with user page.
  if (textField == passwordText || textField == confirmPasswordText) {
    scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
  } else if (textField == screenNameText || textField == emailText) {
    scrollView.contentOffset = CGPointMake(0.0f, 88.0f);
  }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == passwordText) {
    [confirmPasswordText becomeFirstResponder];
  } else if (textField == confirmPasswordText) {
    [screenNameText becomeFirstResponder];
  } else if (textField == screenNameText) {
    [emailText becomeFirstResponder];
  } else if (textField == emailText) {
    [emailText resignFirstResponder];
    [self onSaveClicked];
  }
  
  return NO;
}


#pragma mark UIViewController Methods


- (void)viewDidAppear:(BOOL)animated {
  NSError *error;
  [[GANTracker sharedTracker] trackPageview:@"/user-settings" withError:&error];
}


#pragma mark -


- (IBAction)onDoneClicked {
  [passwordText becomeFirstResponder];
  [passwordText resignFirstResponder];
}


- (IBAction)onPhotoCreditClicked {
  CcSettings *settings = [CcAppDelegate instance].settings;

  NSString *sourceId = [settings stringValueForKey:@"avatar.source-id" defaultValue:nil];
  if ([sourceId hasPrefix:@"http://"]) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sourceId]];
  }
}


- (IBAction)onSaveClicked {
  [self onDoneClicked];

  if ([confirmPasswordText.text isEqualToString:@""]) {
    CcSettings *settings = [CcAppDelegate instance].settings;
    NSString *originalPassword =
        [settings stringValueForKey:@"authentication.password" defaultValue:@""];
    if (![passwordText.text isEqualToString:originalPassword]) {
      [CcUtils alert:@"Please confirm your password."];
      [confirmPasswordText becomeFirstResponder];
      return;
    }
  } else if (![confirmPasswordText.text isEqualToString:passwordText.text]) {
    [CcUtils alert:@"The passwords do not match.  Please re-enter them."];
    passwordText.text = @"";
    confirmPasswordText.text = @"";
    [passwordText becomeFirstResponder];
    return;
  }

  if ([screenNameText.text isEqualToString:@""]) {
    [CcUtils alert:@"Please enter your screen name."];
    return;
  }

  if ([emailText.text isEqualToString:@""]) {
    [CcUtils alert:@"Please enter an email address."];
    return;
  }

  [self tryToUpdateAccount];
}


- (IBAction)onSelectAvatarClicked {
  CcMediaPicker *mediaPicker = [[[CcMediaPicker alloc] init] autorelease];
  mediaPicker.creativeCommonsOnly = YES;
  mediaPicker.delegate = self;

  [self.navigationController pushViewController:mediaPicker animated:YES];
}


- (IBAction)onSignoutClicked {
  NSURL *url = [NSURL URLWithStringWithFormat:@"%@/user/logout/", kServerRootUrl];
  [[CcPlistHttpRequest requestUrl:url
                       method:@"GET"
                       data:nil
                       useStandardErrorHandling:YES]
       send];

  CcSettings *settings = [CcAppDelegate instance].settings;
  [settings setIntValue:0 forKey:@"authentication.logged-in"];
  [settings setStringValue:@"" forKey:@"authentication.username"];
  [settings setStringValue:@"" forKey:@"authentication.password"];
  [settings setStringValue:@"" forKey:@"authentication.name"];
  [settings setStringValue:@"" forKey:@"authentication.email"];
  [settings setStringValue:@"" forKey:@"avatar.source-author"];
  [settings setStringValue:@"" forKey:@"avatar.source-id"];
  [settings setStringValue:@"" forKey:@"avatar.source-type"];

  [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onTextChanged {
  BOOL enable = NO;
  
  enable = ![passwordText.text isEqualToString:@""] && ![screenNameText.text isEqualToString:@""] &&
               ![emailText.text isEqualToString:@""];
  
  [saveButton setEnabled:enable];
}


- (UIScrollView *)scrollViewForKeyboardInteraction {
  return scrollView;
}


#pragma mark Private


- (void)onAccountUpdateResponse:(NSHTTPURLResponse *)response
        data:(NSData *)data
        request:(CcHttpRequest *)theRequest {
  self.request = nil;

  CcSettings *settings = [CcAppDelegate instance].settings;
  [settings setStringValue:[theRequest.data valueForKey:@"password"] forKey:@"authentication.password"];
  [settings setStringValue:[theRequest.data valueForKey:@"screen_name"]
            forKey:@"authentication.name"];
  [settings setStringValue:[theRequest.data valueForKey:@"email"] forKey:@"authentication.email"];

  [CcUtils alert:@"Account successfully updated"];
}


- (void)onImageUploadResponse:(NSHTTPURLResponse *)response
        data:(NSData *)data
        request:(CcHttpRequest *)theRequest {
  uploadProgressBar.hidden = YES;

  self.imageRequest = nil;

  CcSettings *settings = [CcAppDelegate instance].settings;
  NSString *userGuid = [settings stringValueForKey:@"authentication.guid" defaultValue:nil];

  NSURL *url = [NSURL avatarUrlForUserWithGuid:userGuid large:YES];
  [CcLocalCache removeCachedDataForUrl:url];
  self.imageRequest = [avatar setImageWithUrl:url];

  // Also clearing cache for small avatar.
  [CcLocalCache removeCachedDataForUrl:[NSURL avatarUrlForUserWithGuid:userGuid large:NO]];
}


- (void)onImageUploadData:(NSData *)data
        progress:(NSArray *)progress
        request:(CcHttpRequest *)request {
  uploadProgressBar.progress = [[progress objectAtIndex:0] floatValue];
}


- (void)onNetworkError:(NSError *)error request:(CcHttpRequest *)theRequest {
  self.imageRequest = nil;
  self.request = nil;

  uploadProgressBar.progress = 0.0f;
  uploadProgressBar.hidden = YES;
}


- (void)tryToUpdateAccount {
  NSURL *url = [NSURL URLWithStringWithFormat:@"%@/user/update/", kSecureServerRootUrl];
  NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                            kIphoneSecretKey, @"iphone_secret_key",
                            passwordText.text, @"password",
                            screenNameText.text, @"screen_name",
                            emailText.text, @"email",
                            nil];
  self.request = [CcPlistHttpRequest requestUrl:url
                                     method:@"POST"
                                     data:data
                                     useStandardErrorHandling:YES];
  self.request.target = self;
  self.request.onError = @selector(onNetworkError:request:);
  self.request.onSuccess = @selector(onAccountUpdateResponse:data:request:);
  [self.request send];
}


- (void)updatePhotoCreditButton {
  CcSettings *settings = [CcAppDelegate instance].settings;

  NSString *sourceAuthor = [settings stringValueForKey:@"avatar.source-author" defaultValue:@""];
  NSString *sourceType = [settings stringValueForKey:@"avatar.source-type" defaultValue:@""];
  if ([sourceAuthor length]) {
    if ([sourceType length]) {
      [photoCreditButton setTitle:[NSString stringWithFormat:@"%@ @ %@", sourceAuthor, sourceType]];
    } else {
      [photoCreditButton setTitle:sourceAuthor];
    }
    
    photoCreditButton.hidden = NO;
  } else {
    photoCreditButton.hidden = YES;
  }
}


@end
