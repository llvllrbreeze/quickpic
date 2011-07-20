@protocol CcDraggable;


@protocol CcDroppable

@property (nonatomic, readonly) UIView *dropTargetView;

- (BOOL)acceptsAnyOfTheseFlavors:(NSSet *)flavors;
- (void)acceptDroppedObject:(NSObject <CcDraggable> *)draggable;
- (void)draggableObjectsAreReadyToBeDropped:(BOOL)ready;

@end
