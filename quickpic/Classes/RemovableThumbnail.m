#import "RemovableThumbnail.h"

#import "DeleteDelegate.h"


@implementation RemovableThumbnail


@synthesize deleteDelegate;


#pragma mark Initialization


- (id)initWithImage:(UIImage *)image {
  if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)]) {
    UIImage *thumbnail = [image thumbnail:CGSizeMake(80.0f, 80.0f)];
    UIImageView *thumbnailView = [[[UIImageView alloc] initWithImage:thumbnail] autorelease];
    [self addSubview:thumbnailView];
    
    deleteButton = [[[UIButton alloc] initWithFrame:CGRectMake(-5.0f, -3.0f, 26.0f, 29.0f)]
                        autorelease];
    deleteButton.hidden = YES;
    [deleteButton addTarget:self
                  action:@selector(onDeleteClicked)
                  forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setImage:[UIImage imageNamed:@"deleteXUp.png"]];
    [deleteButton setImage:[UIImage imageNamed:@"deleteXDown.png"]
                  forState:UIControlStateHighlighted];
    [self addSubview:deleteButton];
  }
  return self;
}


#pragma mark UIResponder Methods


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  deleteButton.hidden = NO;

  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideDeleteButton) object:nil];
  [self performSelector:@selector(hideDeleteButton) withObject:nil afterDelay:3.0f];
}


#pragma mark Private Methods


- (void)hideDeleteButton {
  deleteButton.hidden = YES;
  [CcAnimationUtils setupAnimationWithStyle:@"cross-fade" forView:deleteButton];
}


- (void)onDeleteClicked {
  [deleteDelegate performSelector:@selector(deleteRequested:) withObject:self];
}


@end
