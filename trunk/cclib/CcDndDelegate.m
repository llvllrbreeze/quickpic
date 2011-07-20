#import "CcDndDelegate.h"

#import "CcAppDelegate.h"
#import "CcDraggable.h"
#import "CcDragEventDelegate.h"
#import "CcDroppable.h"


@interface CcDndDelegate ()
  @property (nonatomic, retain) UIView *dragView;
  @property (nonatomic, retain) NSMutableSet *draggable;
  @property (nonatomic, retain) NSObject <CcDraggable> *dragging;
  @property (nonatomic, retain) NSMutableSet *droppable;
  @property (nonatomic, retain) NSSet *flavors;
@end


@implementation CcDndDelegate


@synthesize dragEventDelegate;
@synthesize dragView;
@synthesize draggable;
@synthesize dragging;
@synthesize droppable;
@synthesize flavors;


#pragma mark Initialization


- (id)initWithView:(UIView *)aView {
  if (self = [super init]) {
    self.view = aView;

    self.draggable = [NSMutableSet set];
    self.droppable = [NSMutableSet set];
  }
  return self;
}


#pragma mark Cleanup


- (void) dealloc {
  self.dragView = nil;
  self.draggable = nil;
  self.dragging = nil;
  self.droppable = nil;
  self.flavors = nil;

  [super dealloc];
}


#pragma mark Touch Handlers


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  
  for (NSObject <CcDraggable> *draggableItem in self.draggable) {
    CGPoint location = [touch locationInView:draggableItem.dragSourceView];
    if ([draggableItem.dragSourceView pointInside:location withEvent:event] &&
            [draggableItem readyToBeDragged]) {
      self.dragging = draggableItem;
    }
  }

  [super touchesBegan:touches withEvent:event];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!self.dragging) {
    return;
  }

  [self.dragView removeFromSuperview];
  self.dragView = nil;
  self.flavors = nil;
  
  self.dragging = nil;

  for (NSObject <CcDroppable> *dropTarget in self.droppable) {
    [dropTarget draggableObjectsAreReadyToBeDropped:NO];
  }

  [super touchesCancelled:touches withEvent:event];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!self.dragging) {
    return;
  }

  UITouch *touch = [touches anyObject];
  
  for (NSObject <CcDroppable> *dropTarget in self.droppable) {
    CGPoint location = [touch locationInView:dropTarget.dropTargetView];
    BOOL canBeDropped = NO;
    if ([dropTarget.dropTargetView pointInside:location withEvent:event]) {
      canBeDropped = [dropTarget acceptsAnyOfTheseFlavors:self.flavors];
    }
    
    if (canBeDropped) {
      [dropTarget acceptDroppedObject:self.dragging];
    }

    [dropTarget draggableObjectsAreReadyToBeDropped:NO];
  }

  [self.dragView removeFromSuperview];
  self.dragView = nil;
  self.flavors = nil;

  self.dragging = nil;

  [super touchesEnded:touches withEvent:event];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];

  if (!self.dragging) {
    return;
  }
  
  if (!self.dragView) {
    self.dragView = self.dragging.dragView;
    self.flavors = self.dragging.flavors;

    [appDelegate.window addSubview:self.dragView];

    [self.dragEventDelegate dragStarted:self.dragging];
  }
  
  UITouch *touch = [touches anyObject];

  CGPoint location = [touch locationInView:appDelegate.window];
  
  CGSize dragViewFrameSize = dragView.frame.size;
  self.dragView.frame = CGRectMake(location.x - dragViewFrameSize.width / 2,
                                   location.y - dragViewFrameSize.height / 2,
                                   dragViewFrameSize.width,
                                   dragViewFrameSize.height);

  for (NSObject <CcDroppable> *dropTarget in self.droppable) {
    CGPoint location = [touch locationInView:dropTarget.dropTargetView];
    BOOL canBeDropped = NO;
    if ([dropTarget.dropTargetView pointInside:location withEvent:event]) {
      canBeDropped = [dropTarget acceptsAnyOfTheseFlavors:self.flavors];
    }
    
    [dropTarget draggableObjectsAreReadyToBeDropped:canBeDropped];
  }

  [super touchesMoved:touches withEvent:event];
}


#pragma mark -


- (void)addDraggable:(NSObject <CcDraggable> *)aDraggable {
  [self.draggable addObject:aDraggable];
}


- (void)addDroppable:(NSObject <CcDroppable> *)aDroppable {
  [self.droppable addObject:aDroppable];
}


- (void)removeDraggable:(NSObject <CcDraggable> *)aDraggable {
  [self.draggable removeObject:aDraggable];
}


- (void)removeDroppable:(NSObject <CcDroppable> *)aDroppable {
  [self.droppable removeObject:aDroppable];
}


@end
