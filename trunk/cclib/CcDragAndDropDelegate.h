@protocol CcDragEventDelegate;
@protocol CcDraggable;
@protocol CcDroppable;


@protocol CcDragAndDropDelegate

@property (nonatomic, assign) NSObject <CcDragEventDelegate> *dragEventDelegate;

- (void)addDraggable:(NSObject <CcDraggable> *)draggable;
- (void)addDroppable:(NSObject <CcDroppable> *)droppable;
- (void)removeDraggable:(NSObject <CcDraggable> *)draggable;
- (void)removeDroppable:(NSObject <CcDroppable> *)droppable;

@end
