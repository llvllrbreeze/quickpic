@protocol CcDraggable

@property (nonatomic, readonly) UIView *dragSourceView;
@property (nonatomic, readonly) UIView *dragView;
@property (nonatomic, readonly) NSSet *flavors;

- (BOOL)readyToBeDragged;
- (id)valueForFlavor:(NSString *)flavor;

@end
