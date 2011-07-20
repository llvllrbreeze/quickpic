@class CcMedia;
@class CcMediaPicker;


@protocol CcMediaPickerDelegate

- (void)mediaPickerController:(CcMediaPicker *)picker
        didFinishPickingMedia:(CcMedia *)media
        mediaId:(int)mediaId;

@end
