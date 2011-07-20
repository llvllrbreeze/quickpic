#import "CcMediaDataSourceItemPickerRow.h"

#import "../UIButton+cliqcliq.h"
#import "../UIImage+cliqcliq.h"
#import "CcMediaPickedDelegate.h"
#import "CcMaskedImage.h"


static UIImage *reflectionMask = nil;

void photoPickerRowStaticInitializer() {
  if (!reflectionMask) {
    reflectionMask = [[UIImage imageNamed:@"photoPickerReflectionMask.png"] retain];
  }
}


@implementation CcMediaDataSourceItemPickerRow


@synthesize delegate;


#pragma mark Initialization


- (id)initWithStartingIndex:(int)theStartingIndex {
  photoPickerRowStaticInitializer();

  if (self = [super init]) {
    startingIndex = theStartingIndex;
  }
  return self;
}


- (void)viewDidLoad {
  for (int index = 0; index < 4; index++) {
    [self setImage:nil atIndex:index];
  }
}


#pragma mark -


- (UITableViewCell *)cell {
  return (UITableViewCell *) self.view;
}


- (IBAction)onButtonClicked:(UIButton *)sender {
  UIButton *buttons[] = {button1, button2, button3, button4};
  
  for (int index = 0; index < 4; index++) {
    if (sender == buttons[index]) {
      [self.delegate mediaPicked:startingIndex + index];
    }
  }
}


- (void)setErrorImageAtIndex:(int)index {
  UIButton *buttons[] = {button1, button2, button3, button4};

  [buttons[index] setBackgroundImage:[UIImage imageNamed:@"photoPickerErrorLoadingPhoto.png"]];
  buttons[index].hidden = NO;
}


- (void)setImage:(UIImage *)image atIndex:(int)index {
  UIButton *buttons[] = {button1, button2, button3, button4};
  
  [buttons[index] setBackgroundImage:image];
  buttons[index].hidden = !image;

  if (image) {
    image = [UIImage flipVertically:image];
    CcMaskedImage *reflectionView = [[[CcMaskedImage alloc] initWithImage:image
                                                            mask:reflectionMask] autorelease];
    reflectionView.frame = CGRectOffset(buttons[index].frame,
                                        0,
                                        buttons[index].frame.size.height + 1);
    [self.view insertSubview:reflectionView atIndex:0];
    [self.releaseOnDealloc addObject:reflectionView];
  }
}


- (void)setLoadingImageAtIndex:(int)index {
  UIButton *buttons[] = {button1, button2, button3, button4};

  [buttons[index] setBackgroundImage:[UIImage imageNamed:@"photoPickerNonLoadedPhoto.png"]];
  buttons[index].hidden = NO;
}


- (UIView *)viewAtIndex:(int)index {
  UIButton *buttons[] = {button1, button2, button3, button4};
  
  return buttons[index];
}


@end
