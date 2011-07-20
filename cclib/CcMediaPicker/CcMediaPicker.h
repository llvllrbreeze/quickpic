#import <UIKit/UIKit.h>

#import "CcMediaDataAvailabilityChangedDelegate.h"
#import "CcMediaPickedDelegate.h"


#define kUTTypeImage @"public.image"
#define kUTTypeMovie @"public.movie"


typedef enum {
  CcMediaPickerSourceCamera = 0,
  CcMediaPickerSourcePhotoLibrary,
  CcMediaPickerSourceNumSources
} CcMediaPickerSource;


@class CcMedia;
@protocol CcMediaDataSource;
@protocol CcMediaPickerDelegate;
@class CcMediaLoadingOverlay;
@protocol CcMediaPickerPlugin;


@interface CcMediaPicker : UIViewController <CcMediaDataAvailabilityChangedDelegate,
                                             CcMediaPickedDelegate,
                                             UIImagePickerControllerDelegate,
                                             UINavigationControllerDelegate> {
@private
  BOOL allowsEditing;
  BOOL allowsImages;
  BOOL allowsVideo;
  IBOutlet UIImageView *confirmationImageView;
  IBOutlet UIView *confirmationView;
  BOOL creativeCommonsOnly;
  NSMutableArray *customButtons;
  IBOutlet UIView *customButtonsView;
  NSObject <CcMediaPickerDelegate> *delegate;
  NSObject <CcMediaDataSource> *lastDataSource;
  CcMedia *lastSelectedMedia;
  int lastSelectedMediaId;
  int lastSelectedSource;
  CcMediaLoadingOverlay *loadingOverlay;
  IBOutlet UIButton *photoAlbumsButton;
  NSMutableArray *plugins;
  int spaceUsedInCustomButtonsView;
  IBOutlet UIButton *takePhotoButton;
  IBOutlet UIActivityIndicatorView *waitingIndicator;
  IBOutlet UIView *waitingOverlay;
}

@property (nonatomic, assign) BOOL allowsEditing;
@property (nonatomic, assign) BOOL allowsImages;
@property (nonatomic, assign) BOOL allowsVideo;
@property (nonatomic, assign) BOOL creativeCommonsOnly;
@property (nonatomic, readonly) UIView *customButtonsView;
@property (nonatomic, assign) NSObject <CcMediaPickerDelegate> *delegate;
@property (nonatomic, readonly) CGFloat requiredHeight;
@property (nonatomic, readonly) int spaceUsedInCustomButtonsView;

- (BOOL)isSourceAvailable:(NSUInteger)source;
- (IBAction)onConfirmed;
- (IBAction)onNotConfirmed;
- (IBAction)onPhotoAlbumsClicked;
- (IBAction)onTakePhotoClicked;
- (void)registerPlugin:(NSObject <CcMediaPickerPlugin> *)plugin;
- (void)selectSource:(NSUInteger)source;

@end
