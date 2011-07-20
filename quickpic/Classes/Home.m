#import "Home.h"

#import "AppDelegate.h"
#import "CellFactory.h"
#import "Constants.h"
#import "RemovableThumbnail.h"
#import "SettingsPage.h"
#import "UploadManager.h"


#define MAX_THUMBS_WITHOUT_SCROLLING 3

static const CGFloat kHomeThumbMargin = 4.0f;
static const CGFloat kHomeThumbSize = 80.0f;

static NSString *kHomeAddressBookKey = @"address-book";
static NSMutableArray *kHomeContactsKeys;
static NSMutableDictionary *kHomeHandlers;
static NSDictionary *kHomeIcons;
static NSString *kHomeImagePickerKey = @"image-picker";
static NSArray *kHomeKeys;
static NSDictionary *kHomeLabels;
static NSMutableArray *kHomeOtherKeys;
static NSMutableArray *kHomePhotoPickerKeys;
static NSMutableArray *kHomeSectionNames;


static BOOL kHomeStaticInitialized = NO;
void homeStaticInitializer() {
  if (kHomeStaticInitialized) {
    return;
  }

  kHomeContactsKeys = [[NSMutableArray arrayWithObject:kHomeAddressBookKey] retain];
  kHomePhotoPickerKeys = [[NSMutableArray arrayWithObjects:kHomeImagePickerKey, nil] retain];
  kHomeOtherKeys = [[NSMutableArray arrayWithObjects:@"settings", nil] retain];
  kHomeKeys = [[NSArray arrayWithObjects:kHomeContactsKeys,
                                         kHomePhotoPickerKeys,
                                         kHomeOtherKeys,
                                         nil] retain];

  kHomeSectionNames = [[NSMutableArray arrayWithObjects:@"", @"", @"", nil] retain];

  kHomeIcons = [[NSDictionary dictionaryWithObjectsAndKeys:
                     [UIImage imageNamed:@"buttonIcon_addressBook.png"], kHomeAddressBookKey,
                     [UIImage imageNamed:@"buttonIcon_settings.png"], @"settings",
                     nil] retain];

  kHomeLabels = [[NSDictionary dictionaryWithObjectsAndKeys:
                      @"Address Book", kHomeAddressBookKey,
                      @"Settings", @"settings",
                      nil] retain];

  kHomeHandlers = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
                        NSStringFromSelector(@selector(onAddressBookClicked)), kHomeAddressBookKey,
                        NSStringFromSelector(@selector(onSettingsClicked)), @"settings",
                        nil] retain];

  kHomeStaticInitialized = YES;
}


@interface Home ()
  @property (nonatomic, retain) NSMutableArray *contacts;
  @property (nonatomic, assign) BOOL isFirstLoad;
  @property (nonatomic, retain) NSMutableArray *media;
  @property (nonatomic, retain) UIView *realView; // Don't allow the initially allocated view to be unloaded
  @property (nonatomic, retain) UploadManager *uploadManager;

  - (void)addOrReplaceMedia:(CcMedia *)media;
  - (void)confirmPersonData:(NSDictionary *)personData;
  - (void)finish;
  - (void)openContinueToUrl:(BOOL)success;
  - (NSString *)parentheticalTextForHeaderWithAllMultiple:(BOOL)allowMultiple min:(int)min;
  - (void)pickContact;
  - (void)pickImage:(NSNumber *)sourceTypeNumber;
  - (void)removeContactPreview;
  - (void)showContactConfirmation:(NSDictionary *)personData;
  - (void)showContactPicker;
  - (void)showEmail;
  - (void)updatePhotosCellContentSize;
  - (void)updateView;
@end


@implementation Home


@synthesize contacts;
@synthesize doneButton = _doneButton;
@synthesize isFirstLoad;
@synthesize media;
@synthesize photosCell = _photosCell;
@synthesize photosCellScrollView = _photosCellScrollView;
@synthesize realView = _realView;
@synthesize uploadManager;


#pragma mark Initialization


- (id)init {
  homeStaticInitializer();

  if (self = [super initWithNibName:@"Home" bundle:[NSBundle mainBundle]]) {
    self.contacts = [NSMutableArray array];
    self.media = [NSMutableArray array];

    self.handlers = kHomeHandlers;
    self.icons = kHomeIcons;
    self.isFirstLoad = YES;
    self.keys = kHomeKeys;
    self.labels = kHomeLabels;
    self.sectionNames = kHomeSectionNames;
  }
  return self;
}


- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Home";
  self.navigationItem.hidesBackButton = YES;
  self.navigationItem.titleView = headerLogo;

  if (self.isFirstLoad) {
    self.realView = self.view;
    self.isFirstLoad = NO;
    [self reset];
  }
  else {
    [self updateView];
  }
}


#pragma mark Cleanup


- (void)dealloc {
  self.contacts = nil;
  self.doneButton = nil;
  self.media = nil;

  [mediaPicker release];
  mediaPicker = nil;

  [mediaPickerCell release];
  mediaPickerCell = nil;

  self.photosCell = nil;
  self.photosCellScrollView = nil;
  self.realView = nil;
  self.uploadManager = nil;

  [super dealloc];
}


#pragma mark ABPeoplePickerNavigationControllerDelegate Methods


- (void)peoplePickerNavigationControllerDidCancel:
    (ABPeoplePickerNavigationController *)peoplePicker {
  [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
        shouldContinueAfterSelectingPerson:(ABRecordRef)person {
  AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];

  if (appDelegate.getContactField) {
    return YES;
  } else {
    NSDictionary *personData = [PersonDataUtils personDataFromAddressBookPersonRecord:person];

    [self dismissModalViewControllerAnimated:YES];

    [self showContactConfirmation:personData];

    return NO;
  }
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
        shouldContinueAfterSelectingPerson:(ABRecordRef)person
        property:(ABPropertyID)property
        identifier:(ABMultiValueIdentifier)identifier {
  AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];
  NSString *contactField = appDelegate.getContactField;
  
  int getPropertyId = -1;
  if ([contactField isEqualToString:@"email"]) {
    getPropertyId = kABPersonEmailProperty;
  } else if ([contactField isEqualToString:@"phone"]) {
    getPropertyId = kABPersonPhoneProperty;
  }

  if (property == getPropertyId) {
    ABMultiValueRef values = ABRecordCopyValue(person, property);
    CFStringRef value = ABMultiValueCopyValueAtIndex(values, identifier);
    NSString *valueString = (NSString *) value;

    NSMutableDictionary *personData =
        (NSMutableDictionary *) [PersonDataUtils personDataFromAddressBookPersonRecord:person];
    [personData setValue:valueString forKey:@"selected-field-value"];

    [self dismissModalViewControllerAnimated:YES];

    [self confirmPersonData:personData];

    return NO;
  }
  
  return YES;
}


#pragma mark CcMediaPickerControllerDelegate


- (void)mediaPickerController:(CcMediaPicker *)picker
        didFinishPickingMedia:(CcMedia *)theMedia
        mediaId:(int)mediaId {
  [self addOrReplaceMedia:theMedia];

  AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];
  if (!appDelegate.getContactInfo && !appDelegate.allowMultipleMedia) {
    [self finish];
  }
}


#pragma mark DeleteDelegate Methods


- (void)deleteRequested:(UIView *)sender {
  [media removeObjectAtIndex:sender.tag];

  [UIView beginAnimations:@"slide" context:nil];
  [UIView setAnimationDuration:0.25];

  for (UIView *subView in [self.photosCellScrollView subviews]) {
    if (subView.tag > sender.tag) {
      subView.tag--;
      subView.frame =
          CGRectWithX(subView.frame, subView.frame.origin.x - kHomeThumbSize - kHomeThumbMargin);
    }
  }

  [UIView commitAnimations];

  [sender removeFromSuperview];

  if ([media count] <= MAX_THUMBS_WITHOUT_SCROLLING) {
    [self.photosCellScrollView setContentOffset:CGPointZero animated:YES];
  }

  [self updatePhotosCellContentSize];

  [self updateView];
}


#pragma mark MFMailComposeViewControllerDelegate Methods


- (void)mailComposeController:(MFMailComposeViewController *)controller
        didFinishWithResult:(MFMailComposeResult)result
        error:(NSError*)error {    
  if (error) {
    [CcUtils alert:[error localizedDescription]];
  } else if (result == MFMailComposeResultSent) {
    NSError *error;
    [[GANTracker sharedTracker] trackEvent:@"quickpic"
                                action:@"email-sent"
                                label:@""
                                value:-1
                                withError:&error];

    [CcUtils alert:@"Email sent successfully"];

    [self.media removeAllObjects];
    [self.photosCellScrollView removeAllSubviews];

    [self updateView];
  }

  [self dismissModalViewControllerAnimated:YES];
}


#pragma mark UITableViewDataSource Methods


- (UITableViewCell *)tableView:(UITableView *)aTableView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  int row = indexPath.row;

  NSArray *sectionKeys = [self.keys objectAtIndex:indexPath.section];
  NSString *key = row < [sectionKeys count] ? [sectionKeys objectAtIndex:row] : nil;
  
  if (sectionKeys == kHomeContactsKeys && key != kHomeAddressBookKey) {
    return [CellFactory addressBookItemCellForTable:aTableView
                        personData:[self.contacts objectAtIndex:row - 1]];
  } else if (sectionKeys == kHomePhotoPickerKeys) {
    if (key == kHomeImagePickerKey) {
      return mediaPickerCell;
    } else {
      return self.photosCell;
    }
  } else {
    return [super tableView:aTableView cellForRowAtIndexPath:indexPath];
  }
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
  NSArray *sectionKeys = [self.keys objectAtIndex:section];

  AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];

  if (sectionKeys == kHomeContactsKeys) {
    return appDelegate.getContactInfo ? 1 + [self.contacts count] : 0;
  } else if (sectionKeys == kHomePhotoPickerKeys) {
    BOOL allowMedia = appDelegate.allowImages || appDelegate.allowVideo;
    return allowMedia ? 1 + ([self.media count] > 0 ? 1 : 0) : 0;
  } else {
    return [super tableView:aTableView numberOfRowsInSection:section];
  }
}


#pragma mark UITableViewDelegate Methods


- (void)tableView:(UITableView *)aTableView
        commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
        forRowAtIndexPath:(NSIndexPath *)indexPath {
  int row = indexPath.row;

  NSArray *sectionKeys = [self.keys objectAtIndex:indexPath.section];

  if (editingStyle == UITableViewCellEditingStyleDelete) {
    if (sectionKeys == kHomeContactsKeys) {
      [self.contacts removeObjectAtIndex:row - 1];
    } else {
      [self.media removeObjectAtIndex:row - 1];
    }

    [self updateView];
  }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
                               editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  int row = indexPath.row;

  NSArray *sectionKeys = [self.keys objectAtIndex:indexPath.section];
  NSString *key = row < [sectionKeys count] ? [sectionKeys objectAtIndex:row] : nil;
  
  if (sectionKeys == kHomeContactsKeys && key != kHomeAddressBookKey) {
    return UITableViewCellEditingStyleDelete;
  } else {
    return UITableViewCellEditingStyleNone;
  }
}


- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  int row = indexPath.row;
  
  NSArray *sectionKeys = [self.keys objectAtIndex:indexPath.section];
  NSString *key = row < [sectionKeys count] ? [sectionKeys objectAtIndex:row] : nil;
  
  if (sectionKeys == kHomeContactsKeys && key != kHomeAddressBookKey) {
    return [CellFactory heightForAddressBookItemCellForTable:aTableView];
  } else if (sectionKeys == kHomePhotoPickerKeys) {
    if (key == kHomeImagePickerKey) {
      return mediaPicker.requiredHeight;
    } else {
      return self.photosCell.frame.size.height;
    }
  } else {
    return [super tableView:aTableView heightForRowAtIndexPath:indexPath];
  }
}


#pragma mark UIViewController Methods


- (void)didReceiveMemoryWarning {
    // Do nothing
}


- (void)loadView {
    if (self.realView) {
        self.view = self.realView;
    }
    else {
        [super loadView];
    }
}


- (void)viewDidAppear:(BOOL)animated {
  NSError *error;
  [[GANTracker sharedTracker] trackPageview:@"/home" withError:&error];
}


#pragma mark UploadDelegate Methods


- (void)uploadCompletedSuccessfully:(UploadManager *)sender {
  AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];

  if (appDelegate.continueToUrl) {
    [self openContinueToUrl:YES];
  }

  [uploadView removeFromSuperview];

  appDelegate.resetHomeWhenBecomingActive = YES;
  [(AppDelegate *) [UIApplication sharedApplication].delegate openedWithUrl:nil];
  [self reset];
}


- (BOOL)upload:(UploadManager *)sender errorOccurred:(NSError *)error {
  message.text = @"An error occurred.  Retrying in 10 seconds...";
  uploadProgressBar.progress = 0.0f;

  retryCountdown = 10;

  // Trying again in 10 seconds.
  [self performSelector:@selector(retry) withObject:nil afterDelay:1.0f];
  
  if ([error code] != NSURLErrorDataNotAllowed) {
    return YES;
  } else {
    [self onCancelClicked];
    return NO;
  }
}


- (void)upload:(UploadManager *)sender progress:(float)progress {
  int fileIndex = (int) (progress * [self.media count]);

  if (fileIndex < [self.media count]) {
    CcMedia *mediaItem = [self.media objectAtIndex:fileIndex];
    uploadingImage.image = mediaItem.displayImage;
  }

  uploadProgressBar.progress = progress;
}


- (void)uploadStarted:(UploadManager *)sender {
  [self.view addSubview:uploadView];

  message.text = @"uploading";
  uploadProgressBar.progress = 0.0f;
}


#pragma mark -


- (IBAction)onCancelClicked {
  [self.uploadManager cancel];

  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(retry) object:nil];

  [uploadView removeFromSuperview];

  self.navigationItem.leftBarButtonItem = cancelButton;
  self.navigationItem.rightBarButtonItem = self.doneButton;
}


- (IBAction)onComposeClicked {
  [self finish];
}


- (IBAction)onContactConfirmed {
  NSDictionary *personData = contactPreview.personData;

  [self confirmPersonData:personData];

  [self removeContactPreview];
}


- (IBAction)onContactNotConfirmed {
  [self removeContactPreview];

  [self pickContact];
}


- (IBAction)onDoneClicked {
  [self finish];
}


- (IBAction)onHomeCancelClicked {
  [self openContinueToUrl:NO];
}


- (IBAction)onLogoClicked {
  [[CcAppDelegate instance] showAbout];
}


- (void)reset {
  [self.contacts removeAllObjects];

  [self.photosCellScrollView removeAllSubviews];
  [self.media removeAllObjects];

  AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];

  [mediaPicker release];
  mediaPicker = [[CcMediaPicker alloc] init]; // Not releasing, cleaning up in dealloc.
  mediaPicker.allowsEditing = appDelegate.allowEditing;
  mediaPicker.allowsImages = appDelegate.allowImages;
  mediaPicker.allowsVideo = appDelegate.allowVideo;
  mediaPicker.creativeCommonsOnly = appDelegate.creativeCommonsOnly;
  mediaPicker.delegate = self;
  
  if (appDelegate.allowFlickr) {
    CcFlickrPhotoDataSource *flickrPlugin = [[[CcFlickrPhotoDataSource alloc] init] autorelease];
    [mediaPicker registerPlugin:flickrPlugin];
  }

  [mediaPickerCell release];
  mediaPickerCell = [[UITableViewCell alloc] init]; // Not releasing, cleaning up in dealloc.
  mediaPicker.view.frame = CGRectMake(0.0f, 0.0f, kScreenWidth, mediaPicker.requiredHeight);
  [mediaPickerCell addSubview:mediaPicker.view];

  NSString *contactsSectionName = @"";
  if (appDelegate.getContactInfo) {
    contactsSectionName = appDelegate.allowMultipleContacts ? @"Contacts" : @"Contact";
    
    NSString *parenText =
        [self parentheticalTextForHeaderWithAllMultiple:appDelegate.allowMultipleContacts
              min:appDelegate.minContacts];
    contactsSectionName = [contactsSectionName stringByAppendingFormat:@" (%@)", parenText];
  }
  
  BOOL allowImages = appDelegate.allowImages;
  BOOL allowVideo = appDelegate.allowVideo;
  BOOL allowMultipleMedia = appDelegate.allowMultipleMedia;
  NSString *photoPickerSectionName = @"";
  if (allowImages || allowVideo) {
    if (allowMultipleMedia) {
      if (allowImages && allowVideo) {
        photoPickerSectionName = @"Media";
      } else if (allowImages) {
        photoPickerSectionName = @"Photos";
      } else if (allowVideo) {
        photoPickerSectionName = @"Videos";
      }
    } else {
      if (allowImages && allowVideo) {
        photoPickerSectionName = @"Photo or Video";
      } else if (allowImages) {
        photoPickerSectionName = @"Photo";
      } else if (allowVideo) {
        photoPickerSectionName = @"Video";
      }
    }

    NSString *parenText =
        [self parentheticalTextForHeaderWithAllMultiple:appDelegate.allowMultipleMedia
              min:appDelegate.minMedia];
    photoPickerSectionName = [photoPickerSectionName stringByAppendingFormat:@" (%@)", parenText];
  }
    
  [kHomeSectionNames removeAllObjects];
  [kHomeSectionNames addObject:contactsSectionName];
  [kHomeSectionNames addObject:photoPickerSectionName];
  [kHomeSectionNames addObject:@" "];

  if (appDelegate.getContactInfo && !appDelegate.allowImages && !appDelegate.allowVideo) {
    [self pickContact];
  } else if (!appDelegate.getContactInfo) {
    CcMediaPickerSource source = -1;
    int defaultSource = appDelegate.defaultSource;
    if (defaultSource == DefaultMediaPickerSourceCamera) {
      source = CcMediaPickerSourceCamera;
    } else if (defaultSource == DefaultMediaPickerSourcePhotoLibrary) {
      source = CcMediaPickerSourcePhotoLibrary;
    } else if (defaultSource == DefaultMediaPickerSourceFlickr && appDelegate.allowFlickr) {
      source = 2; // 2 = flickr, the first plugin
    }
    
    if (source >= 0) {
      [self performSelector:@selector(pickImage:)
                 withObject:[NSNumber numberWithInt:source]
                 afterDelay:1.5f]; // Waiting for other animation to finish
      appDelegate.defaultSource = -1;
    }
  }

  UINavigationItem *navigationItem = self.navigationItem;
  if (appDelegate.postToUrl) {
    navigationItem.leftBarButtonItem = cancelButton;
    navigationItem.rightBarButtonItem = self.doneButton;
  } else {
    navigationItem.leftBarButtonItem = nil;
    navigationItem.rightBarButtonItem = composeButton;
  }

  [self updateView];
}


#pragma mark Private


- (void)addOrReplaceMedia:(CcMedia *)theMedia {
  AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];

  [self.navigationController popToViewController:self animated:YES];

  if (!appDelegate.allowMultipleMedia) {
    [self.photosCellScrollView removeAllSubviews];
    [self.media removeAllObjects];
  }

  RemovableThumbnail *thumbnail =
    [[[RemovableThumbnail alloc] initWithImage:theMedia.displayImage] autorelease];
  thumbnail.tag = [self.media count];
  thumbnail.deleteDelegate = self;

  CGFloat offset = (kHomeThumbSize + kHomeThumbMargin) * [self.media count] + kHomeThumbMargin;
  thumbnail.frame = CGRectMake(offset, kHomeThumbMargin, kHomeThumbSize, kHomeThumbSize);
  [self.photosCellScrollView addSubview:thumbnail];

  [self updatePhotosCellContentSize];
  CGFloat scrollOffset = MAX(0.0f, self.photosCellScrollView.contentSize.width - kScreenWidth);
  [self.photosCellScrollView
       setContentOffset:CGPointMake(scrollOffset, 0.0f)
       animated:NO];

  [self.media addObject:theMedia];
  [self updateView];
}


- (void)confirmPersonData:(NSDictionary *)personData {
  int personId = [[personData valueForKey:@"id"] intValue];
  BOOL found = NO;
  for (NSDictionary *contact in contacts) {
    if (personId == [[contact valueForKey:@"id"] intValue]) {
      found = YES;
      break;
    }
  }

  AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];

  if (!found) {
    if (appDelegate.allowMultipleContacts) {
      [self.contacts addObject:personData];
    } else {
      [self.contacts removeAllObjects];
      [self.contacts addObject:personData];
    }
    
    UIImage *image = [personData valueForKey:@"image"];
    if (image) {
      [self addOrReplaceMedia:[CcMedia mediaWithImage:image]];
    }
    
    [self updateView];
  }
  
  if (!appDelegate.allowMultipleContacts && !appDelegate.allowImages && !appDelegate.allowVideo) {
    [self finish];
  }
}


- (void)finish {
  AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];
  
  if (appDelegate.postToUrl) {
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.uploadManager = [[[UploadManager alloc] initWithMedia:self.media
                                                 contacts:self.contacts
                                                 url:[appDelegate.postToUrl url]
                                                 context:appDelegate.postContext] autorelease];
    self.uploadManager.delegate = self;
    [self.uploadManager start];
  } else {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self performSelector:@selector(showEmail) withObject:nil afterDelay:0.0f];
  }
}


- (void)onAddressBookClicked {
  [self pickContact];
}


- (void)onSettingsClicked {
  SettingsPage *settingsPage = [[[SettingsPage alloc] init] autorelease];
  [self.navigationController pushViewController:settingsPage animated:YES];
}


- (void)openContinueToUrl:(BOOL)success {
  AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];

  NSString *urlString = appDelegate.continueToUrl;

  NSString *optContext = appDelegate.passContextToContinueUrl ?
      [NSString stringWithFormat:
           @"&context=%@",
           [appDelegate.postContext stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] :
      @"";

  if ([urlString rangeOfString:@"?"].location == NSNotFound) {
    urlString = [NSString stringWithFormat:@"%@?success=%d%@", urlString, success, optContext];
  } else {
    urlString = [NSString stringWithFormat:@"%@&success=%d%@", urlString, success, optContext];
  }

  [[UIApplication sharedApplication] openURL:[urlString url]];
}


- (NSString *)parentheticalTextForHeaderWithAllMultiple:(BOOL)allowMultiple min:(int)min {
  if (allowMultiple) {
    return min ? [NSString stringWithFormat:@"choose at least %d", min] : @"optional";
  } else {
    return min ? @"required" : @"optional";
  }
}


- (void)pickContact {
  [self showContactPicker];
}


- (void)pickImage:(NSNumber *)sourceTypeNumber {
  int sourceType = [sourceTypeNumber intValue];
  if (sourceType >= 0 && [mediaPicker isSourceAvailable:sourceType]) {
    [mediaPicker selectSource:sourceType];
  }
}


- (void)removeContactPreview {
  [contactConfirmation removeFromSuperview];

  [contactPreview.view removeFromSuperview];
  [contactPreview release];
  contactPreview = nil;
}


- (void)retry {
  retryCountdown--;
  
  if (retryCountdown > 0) {
      message.text = [NSString stringWithFormat:@"An error occurred.  Retrying in %d second%@...",
                                                retryCountdown,
                                                retryCountdown != 1 ? @"s" : @""];
      [self performSelector:@selector(retry) withObject:nil afterDelay:1.0f];
  }
}


- (void)showContactPicker {
  ABPeoplePickerNavigationController *contactPicker =
      [[[ABPeoplePickerNavigationController alloc] init] autorelease];
  contactPicker.peoplePickerDelegate = self;

  [self presentModalViewController:contactPicker animated:YES];
}


- (void)showContactConfirmation:(NSDictionary *)personData {
  [contactPreview release];
  contactPreview = [[CcContactPreview alloc] initWithPersonData:personData]; // Not auto-releasing, cleaning up in removeContactPreview, called after any user interaction.

  [contactConfirmation insertSubview:contactPreview.view atIndex:0];
  contactConfirmation.frame = CGRectWithY(contactConfirmation.frame, 20.0f);
  [[UIApplication sharedApplication].keyWindow addSubview:contactConfirmation];
}


- (void)showEmail {
  MFMailComposeViewController *mailComposer =
      [[[MFMailComposeViewController alloc] init] autorelease];
  mailComposer.mailComposeDelegate = self;
  
  [mailComposer setMessageBody:@"" isHTML:NO];

  CcSettings *settings = [CcAppDelegate instance].settings;
  BOOL thumbnailPhotos = [settings intValueForKey:@"pref.thumbnail-photos" defaultValue:NO];

  int numImages = 0;
  int numMovies = 0;
  int mediaIndex = 0;
  for (CcMedia *mediaItem in self.media) {
    if (mediaItem.image) {
      UIImage *image = mediaItem.image;
      if (thumbnailPhotos) {
        image = [image thumbnail:CGSizeMake(THUMBNAIL_SIZE, THUMBNAIL_SIZE) zoomAndCrop:NO];
      }

      numImages++;
      [mailComposer addAttachmentData:UIImageJPEGRepresentation(image, IMAGE_QUALITY)
                    mimeType:@"image/jpeg"
                    fileName:[NSString stringWithFormat:@"quickpic_%d.jpg", mediaIndex]];
    } else if (mediaItem.movieUrl) {
      numMovies++;
      [mailComposer addAttachmentData:[NSData dataWithContentsOfURL:mediaItem.movieUrl]
                    mimeType:@"video/quicktime"
                    fileName:[NSString stringWithFormat:@"quickpic_%d.mov", mediaIndex]];
    }
    
    mediaIndex++;
  }

  NSString *picturePart = numImages > 0 ?
      [NSString stringWithFormat:@"Picture%@", numImages != 1 ? @"s" : @""] :
      nil;
  NSString *videoPart = numMovies > 0 ?
      [NSString stringWithFormat:@"Video%@", numMovies != 1 ? @"s" : @""] :
      nil;

  NSMutableArray *emailTypeParts = [NSMutableArray array];
  if (picturePart) {
    [emailTypeParts addObject:picturePart];
  }
  if (videoPart) {
    [emailTypeParts addObject:videoPart];
  }
    
  NSString *emailType = [emailTypeParts componentsJoinedByString:@" and "];
  
  NSString *subject = [NSString stringWithFormat:@"%@ sent using Quickpic", emailType];
  [mailComposer setSubject:subject];
  
  [self presentModalViewController:mailComposer animated:YES];

  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)updatePhotosCellContentSize {
  CGFloat offset = (kHomeThumbSize + kHomeThumbMargin) * [media count] + kHomeThumbMargin;
  CGFloat contentWidth = offset + kHomeThumbSize + kHomeThumbMargin;
  self.photosCellScrollView.contentSize =
      CGSizeMake(contentWidth, kHomeThumbSize + kHomeThumbMargin * 2.0f);
}


- (void)updateView {
  [self.tableView reloadData];

  AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];
  
  BOOL canFinish = ([self.contacts count] || [self.media count]) &&
                   [self.contacts count] >= appDelegate.minContacts &&
                   [self.media count] >= appDelegate.minMedia;
  self.doneButton.enabled = canFinish;
  composeButton.enabled = canFinish;
}


@end
