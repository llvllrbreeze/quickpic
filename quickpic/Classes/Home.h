#import <cclib/Cclib.h>

#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "DeleteDelegate.h"
#import "UploadDelegate.h"


@class UploadManager;


@interface Home : CcButtonItemListTableViewController <ABPeoplePickerNavigationControllerDelegate,
                                                       CcMediaPickerDelegate,
                                                       DeleteDelegate,
                                                       MFMailComposeViewControllerDelegate,
                                                       UploadDelegate> {
@private
  IBOutlet UIBarButtonItem *cancelButton;
  IBOutlet UIBarButtonItem *composeButton;
  IBOutlet UIView *contactConfirmation;
  CcContactPreview *contactPreview;
  NSMutableArray *contacts;
  IBOutlet UIButton *headerLogo;
  IBOutlet UIButton *homeCancelButton;
  NSMutableArray *media;
  CcMediaPicker *mediaPicker;
  UITableViewCell *mediaPickerCell;
  IBOutlet UILabel *message;
  int retryCountdown;
  IBOutlet UIImageView *statusBackground;
  IBOutlet UIImageView *uploadingImage;
  UploadManager *uploadManager;
  IBOutlet UIProgressView *uploadProgressBar;
  IBOutlet UIView *uploadView;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem* doneButton;
@property (nonatomic, retain) IBOutlet UITableViewCell* photosCell;
@property (nonatomic, retain) IBOutlet UIScrollView *photosCellScrollView;

- (IBAction)onCancelClicked;
- (IBAction)onComposeClicked;
- (IBAction)onContactConfirmed;
- (IBAction)onContactNotConfirmed;
- (IBAction)onDoneClicked;
- (IBAction)onHomeCancelClicked;
- (IBAction)onLogoClicked;
- (void)reset;

@end
