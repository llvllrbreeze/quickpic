#import "CcMediaPicker.h"

#import <QuartzCore/QuartzCore.h>

#import "../CcAnimationUtils.h"
#import "../CcAppDelegate.h"
#import "../CcConfiguration.h"
#import "../GANTracker.h"
#import "../NSObject+cliqcliq.h"
#import "../UIButton+cliqcliq.h"
#import "../UIImage+cliqcliq.h"
#import "../UIViewController+cliqcliq.h"
#import "CcMedia.h"
#import "CcMediaDataSource.h"
#import "CcMediaDataSourceItemPicker.h"
#import "CcMediaLoadingOverlay.h"
#import "CcMediaPickerDelegate.h"
#import "CcMediaPickerPlugin.h"


@interface CcMediaPicker ()
  @property (nonatomic, retain) NSObject <CcMediaDataSource> *lastDataSource;

  - (void)addPluginToView:(NSObject <CcMediaPickerPlugin> *)plugin;
  - (void)finishMediaPicked:(CcMedia *)media fromBuiltInSourceType:(NSNumber *)sourceTypeNumber;
  - (void)pluginSelected:(UIButton *)target;
  - (void)showConfirmation:(CcMedia *)media mediaId:(int)mediaId;
  - (void)showWaitingOverlay:(BOOL)show;
@end

@implementation CcMediaPicker


@synthesize allowsEditing;
@synthesize allowsImages;
@synthesize allowsVideo;
@synthesize creativeCommonsOnly;
@synthesize customButtonsView;
@synthesize delegate;
@synthesize lastDataSource;
@synthesize spaceUsedInCustomButtonsView;


#pragma mark Initialization


- (id)init {
  if (self = [super init]) {
    plugins = [[NSMutableArray array] retain]; // Retaining, cleaning up in dealloc.
    self.allowsImages = YES;
  }
  return self;
}


- (void)viewDidLoad {
  self.title = @"Photo Sources";
  
  BOOL cameraAvailable =
      [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
  BOOL photoLibraryAvailable =
      [UIImagePickerController
           isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];

  takePhotoButton.enabled = cameraAvailable;
  photoAlbumsButton.enabled = photoLibraryAvailable;

  [takePhotoButton setTitle:self.allowsVideo ?
       (self.allowsImages ? @"New Photo / Video" : @"New Video") : @"New Photo"];
  [photoAlbumsButton setTitle:self.allowsVideo ?
       (self.allowsImages ? @"Photo / Video Library" : @"Video Library") : @"Photo Library"];

  customButtons = [[NSMutableArray arrayWithCapacity:[plugins count]] retain]; // Retaining, cleaning up in dealloc.
}


#pragma mark Cleanup


- (void)dealloc {  
  [customButtons release];
  customButtons = nil;

  self.lastDataSource = nil;

  [lastSelectedMedia release];
  lastSelectedMedia = nil;

  [loadingOverlay release];
  loadingOverlay = nil;

  [plugins release];
  plugins = nil;

  [super dealloc];
}


#pragma mark CcMediaDataAvailabilityChangedDelegate


// TODO(westphal): Add multiple listener support so that the photo picker delegate can keep loading
//                 thumbnails

- (void)mediaProgressChanged:(id <CcMediaDataSource>)target
        mediaIndex:(int)index
        progress:(float)progress {
  loadingOverlay.progress.progress = progress;

  if (progress >= 1.0f) {
    CcMedia *media = [target mediaAtIndex:index];

    [loadingOverlay.view removeFromSuperview];
    [CcAnimationUtils setupAnimationWithStyle:@"cross-fade"
                      forView:[CcAppDelegate instance].window];

    [self showConfirmation:media mediaId:[target mediaIdForMediaAtIndex:index]];
  }
}


#pragma mark CcMediaPickedDelegate


- (void)mediaPicked:(int)mediaIndex {
  [lastDataSource removeDelegate:self]; // Making sure this delegate is only added once.
  [lastDataSource addDelegate:self];
  if ([lastDataSource requestMediaAtIndex:mediaIndex]) {
    CcMedia *media = [lastDataSource mediaAtIndex:mediaIndex];

    [self showConfirmation:media mediaId:[lastDataSource mediaIdForMediaAtIndex:mediaIndex]];
  } else {
    CcAppDelegate *appDelegate = [CcAppDelegate instance];

    loadingOverlay = [[CcMediaLoadingOverlay alloc] init]; // Not releasing, cleaning up in dealloc.
    loadingOverlay.view.frame = CGRectMake(0, 20, 320, 460);
    [loadingOverlay.cancelButton addTarget:self
                                 action:@selector(onCancelClicked)
                                 forControlEvents:UIControlEventTouchUpInside];
    [appDelegate.window addSubview:loadingOverlay.view];
    [CcAnimationUtils setupAnimationWithStyle:@"cross-fade" forView:appDelegate.window];
  }
}


#pragma mark UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingMediaWithInfo:(NSDictionary *)info {
  CcMedia *media = [CcMedia mediaWithImagePickerInfoDictionary:info];
  UIImagePickerControllerSourceType sourceType = picker.sourceType;
  sourceType = sourceType == UIImagePickerControllerSourceTypeCamera ?
      CcMediaPickerSourceCamera :
      CcMediaPickerSourcePhotoLibrary;
    
  [picker dismissModalViewControllerAnimated:YES];

  if (sourceType != CcMediaPickerSourceCamera && media.image && !self.allowsEditing) {
    [self showConfirmation:media mediaId:-1];
  } else {
    [self showWaitingOverlay:YES];

    [self performSelector:@selector(finishMediaPicked:fromBuiltInSourceType:)
          withObject:media
          withObject:[NSNumber numberWithInt:sourceType]
          afterDelay:0.0f];
  }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker dismissModalViewControllerAnimated:YES];
}


#pragma mark UIViewController Methods


- (void)viewDidAppear:(BOOL)animated {
  NSError *error;
  [[GANTracker sharedTracker] trackPageview:@"/advanced-image-picker" withError:&error];
}


#pragma mark -


- (BOOL)isSourceAvailable:(NSUInteger)source {
  BOOL cameraAvailable =
      [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
  BOOL photoLibraryAvailable =
      [UIImagePickerController
           isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];

  if (source == CcMediaPickerSourceCamera) {
    return cameraAvailable;
  } else if (source == CcMediaPickerSourcePhotoLibrary) {
    return photoLibraryAvailable;
  } else {
    return YES;
  }
}


- (void)onCancelClicked {
  [lastDataSource removeDelegate:self];
  [loadingOverlay.view removeFromSuperview];
}


- (IBAction)onConfirmed {
  [confirmationView removeFromSuperview];

  if (lastSelectedSource == CcMediaPickerSourceCamera ||
      lastSelectedSource == CcMediaPickerSourcePhotoLibrary) {
    [self showWaitingOverlay:YES];

    [self performSelector:@selector(finishMediaPicked:fromBuiltInSourceType:)
          withObject:lastSelectedMedia
          withObject:[NSNumber numberWithInt:lastSelectedSource]
          afterDelay:0.0f];
  } else {
    [self.delegate mediaPickerController:self
                   didFinishPickingMedia:lastSelectedMedia
                   mediaId:lastSelectedMediaId];
  }
}


- (IBAction)onNotConfirmed {
  [confirmationView removeFromSuperview];

  if (lastSelectedSource == CcMediaPickerSourceCamera ||
      lastSelectedSource == CcMediaPickerSourcePhotoLibrary) {
    [self selectSource:lastSelectedSource];
  }
}


- (IBAction)onPhotoAlbumsClicked {
  [self selectSource:CcMediaPickerSourcePhotoLibrary];
}


- (IBAction)onTakePhotoClicked {
  [self selectSource:CcMediaPickerSourceCamera];
}


- (void)registerPlugin:(NSObject <CcMediaPickerPlugin> *)plugin {
  [self forceViewToLoad];

  [plugins addObject:plugin];
  [self addPluginToView:plugin];
}


- (CGFloat)requiredHeight {
  [self forceViewToLoad];
  
  return 44.0f * CcMediaPickerSourceNumSources + spaceUsedInCustomButtonsView;
}


- (void)selectSource:(NSUInteger)source {
  [self forceViewToLoad];
  
  if (source == CcMediaPickerSourceCamera || source == CcMediaPickerSourcePhotoLibrary) {
    UIImagePickerController *imagePickerController =
        [[[UIImagePickerController alloc] init] autorelease];
    imagePickerController.allowsEditing = self.allowsEditing;

    UIImagePickerControllerSourceType builtInSourceType =
        source == CcMediaPickerSourceCamera ? 
            UIImagePickerControllerSourceTypeCamera :
            UIImagePickerControllerSourceTypePhotoLibrary;

    NSArray *availableMediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:builtInSourceType];

    NSMutableArray *mediaTypes = [NSMutableArray array];
    if (self.allowsImages && [availableMediaTypes containsObject:kUTTypeImage]) {
      [mediaTypes addObject:kUTTypeImage];
    }
    if (self.allowsVideo && [availableMediaTypes containsObject:kUTTypeMovie]) {
      [mediaTypes addObject:kUTTypeMovie];
    }

    imagePickerController.mediaTypes = mediaTypes;
    
    imagePickerController.delegate = self;

    imagePickerController.sourceType = builtInSourceType;

    [[CcAppDelegate instance].navigationController presentModalViewController:imagePickerController
                                                                     animated:YES];
  } else {
    NSObject <CcMediaDataSource> *dataSource;

    NSObject <CcMediaPickerPlugin> *plugin =
        [plugins objectAtIndex:source - CcMediaPickerSourceNumSources];
    plugin.creativeCommonsOnly = self.creativeCommonsOnly;
    dataSource = plugin.dataSource;

    CcMediaDataSourceItemPicker *itemPicker =
        [[[CcMediaDataSourceItemPicker alloc] initWithDataSource:dataSource] autorelease];
    itemPicker.delegate = self;
    // Using the global instance of the navigationController so that this method can be called
    // without adding the image picker itself to the screen (for directly jumping to a source).
    [[CcAppDelegate instance].navigationController pushViewController:itemPicker animated:YES];

    self.lastDataSource = dataSource;
  }

  lastSelectedSource = source;
}


#pragma mark Private


- (void)addPluginToView:(NSObject <CcMediaPickerPlugin> *)plugin {
  if (!(self.allowsImages && plugin.supportsImages ||
      !(self.allowsVideo && plugin.supportsVideo))) {
    return;
  }

  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.enabled = plugin.isEnabled;
  button.frame = CGRectMake(0, spaceUsedInCustomButtonsView, 320, 44);
  button.adjustsImageWhenHighlighted = NO;
  button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
  button.titleLabel.font = [UIFont systemFontOfSize:17];
  button.titleLabel.shadowOffset = CGSizeMake(0, 1);
  button.titleLabel.textColor = [UIColor whiteColor];
  [button setTitleColor:[UIColor colorWithWhite:0.66f alpha:1.0f]
          forState:UIControlStateDisabled];
  [button setTitleShadowColor:[UIColor blackColor]];
  button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
  button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
  [button setBackgroundImage:[UIImage imageNamed:@"buttonItemUp.png"]];
  [button setBackgroundImage:[UIImage imageNamed:@"buttonItemDown.png"]
          forState:UIControlStateHighlighted];
  [button setBackgroundImage:[UIImage imageNamed:@"buttonItemDisabled.png"]
          forState:UIControlStateDisabled];
  [button setImage:plugin.icon];
  [button setImage:plugin.disabledIcon forState:UIControlStateDisabled];
  [button setTitle:[plugin titleWithSupportForImages:self.allowsImages video:self.allowsVideo]];

  button.tag = [plugins indexOfObject:plugin] + CcMediaPickerSourceNumSources;

  [button addTarget:self
          action:@selector(pluginSelected:)
          forControlEvents:UIControlEventTouchUpInside];

  [customButtons addObject:button];
  spaceUsedInCustomButtonsView += 44;
  
  [customButtonsView addSubview:button];
}


- (void)finishMediaPicked:(CcMedia *)media fromBuiltInSourceType:(NSNumber *)sourceTypeNumber {
  UIImagePickerControllerSourceType sourceType = [sourceTypeNumber intValue];

  // Saving the photo to the photo library if from the camera.
  if (media.image) {
    media.image = [UIImage correctOrientation:media.image];

    if (sourceType == CcMediaPickerSourceCamera) {
      UIImageWriteToSavedPhotosAlbum(media.image, self, nil, nil);
    }
  } else if (media.movieUrl) {
    if (sourceType == CcMediaPickerSourceCamera) {
      // Chops off the "file://localhost" prefix.
      NSString *path = [[media.movieUrl absoluteString] substringFromIndex:16];
      UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
    }
  }

  CcSettings *settings = [CcAppDelegate instance].settings;
  NSString *sourceAuthor = [settings stringValueForKey:@"authentication.name" defaultValue:@""];
  NSString *sourceId = [settings stringValueForKey:@"authentication.guid" defaultValue:@""];
  
  if (![sourceId isEqualToString:@""]) {
    sourceId = [NSString stringWithFormat:@"%@/profile/%@/", kServerRootUrl, sourceId];
  }

  [media setSourceAuthor:sourceAuthor sourceId:sourceId sourceType:@""];

  [self showWaitingOverlay:NO];

  [self.delegate mediaPickerController:self
                 didFinishPickingMedia:media
                 mediaId:-1];
}


- (void)pluginSelected:(UIButton *)target {
  [self selectSource:target.tag];
}


- (void)showConfirmation:(CcMedia *)media mediaId:(int)mediaId {
  [lastSelectedMedia release];
  lastSelectedMedia = [media retain];

  lastSelectedMediaId = mediaId;

  confirmationImageView.image = media.image;

  confirmationView.frame = CGRectMake(0.0f, 20.0f, 320.0f, 460.0f);
  [[UIApplication sharedApplication].keyWindow addSubview:confirmationView];
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


@end
