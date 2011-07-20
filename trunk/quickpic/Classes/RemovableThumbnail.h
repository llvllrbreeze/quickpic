#import <cclib/Cclib.h>


@protocol DeleteDelegate;


@interface RemovableThumbnail : UIView {
@private
  UIButton *deleteButton;
  NSObject <DeleteDelegate> *deleteDelegate;
}

@property (nonatomic, assign) NSObject <DeleteDelegate> *deleteDelegate;

- (id)initWithImage:(UIImage *)image;

@end
