#import <UIKit/UIKit.h>

#import "../CcViewController.h"


@protocol CcMediaPickedDelegate;

@interface CcMediaDataSourceItemPickerRow : CcViewController {
  @private
    IBOutlet UIButton *button1;
    IBOutlet UIButton *button2;
    IBOutlet UIButton *button3;
    IBOutlet UIButton *button4;
    NSObject <CcMediaPickedDelegate> *delegate;
    int startingIndex;
}

@property (nonatomic, assign) NSObject <CcMediaPickedDelegate> *delegate;

- (id)initWithStartingIndex:(int)theStartingIndex;

- (IBAction)onButtonClicked:(UIButton *)sender;
- (void)setErrorImageAtIndex:(int)index;
- (void)setImage:(UIImage *)image atIndex:(int)index;
- (void)setLoadingImageAtIndex:(int)index;
- (UIView *)viewAtIndex:(int)index;

@end
