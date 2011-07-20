#import <UIKit/UIKit.h>


@interface CcMediaLoadingOverlay : UIViewController {
  @private
    IBOutlet UIButton *cancelButton;
    IBOutlet UIProgressView *progress;
}

@property (nonatomic, readonly) UIButton *cancelButton;
@property (nonatomic, readonly) UIProgressView *progress;

@end
