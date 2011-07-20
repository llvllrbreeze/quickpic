#import <cclib/Cclib.h>


typedef enum {
  DefaultMediaPickerSourceCamera = 0,
  DefaultMediaPickerSourcePhotoLibrary,
  DefaultMediaPickerSourceFlickr
} DefaultMediaPickerSource;


extern const NSString *kAppDelegateDatabaseFilename;

@interface AppDelegate : CcAppDelegate {
  BOOL allowEditing;
  BOOL allowFlickr;
  BOOL allowImages;
  BOOL allowMultipleContacts;
  BOOL allowMultipleMedia;
  BOOL allowVideo;
  NSString *continueToUrl;
  BOOL creativeCommonsOnly;
  int defaultSource;
  NSString *getContactField;
  BOOL getContactInfo;
  CGSize maxImageSize;
  int minContacts;
  int minMedia;
  BOOL passContextToContinueUrl;
  NSString *postContext;
  NSString *postToUrl;
}

@property (nonatomic, assign) BOOL allowEditing;
@property (nonatomic, assign) BOOL allowFlickr;
@property (nonatomic, assign) BOOL allowImages;
@property (nonatomic, assign) BOOL allowMultipleContacts;
@property (nonatomic, assign) BOOL allowMultipleMedia;
@property (nonatomic, assign) BOOL allowVideo;
@property (nonatomic, retain) NSString *continueToUrl;
@property (nonatomic, assign) BOOL creativeCommonsOnly;
@property (nonatomic, assign) int defaultSource;
@property (nonatomic, retain) NSString *getContactField;
@property (nonatomic, assign) BOOL getContactInfo;
@property (nonatomic, assign) CGSize maxImageSize;
@property (nonatomic, assign) int minContacts;
@property (nonatomic, assign) int minMedia;
@property (nonatomic, assign) BOOL passContextToContinueUrl;
@property (nonatomic, retain) NSString *postContext;
@property (nonatomic, retain) NSString *postToUrl;
@property (nonatomic, assign) BOOL resetHomeWhenBecomingActive;

- (BOOL)openedWithUrl:(NSURL *)url;
- (void)reset;

@end

