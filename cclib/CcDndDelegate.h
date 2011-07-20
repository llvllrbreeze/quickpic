#import <UIKit/UIKit.h>

#import "CcDragAndDropDelegate.h"


@protocol CcDragEventDelegate;

@interface CcDndDelegate : UIViewController <CcDragAndDropDelegate> {
@private
  NSObject <CcDragEventDelegate> *dragEventDelegate;
  UIView *dragView;
  NSMutableSet *draggable;
  NSObject <CcDraggable> *dragging;
  NSMutableSet *droppable;
  NSSet *flavors;
}

- (id)initWithView:(UIView *)aView;

@end
