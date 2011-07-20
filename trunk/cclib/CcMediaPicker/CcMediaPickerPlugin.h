@protocol CcMediaPickerPlugin

@property (nonatomic, assign) BOOL creativeCommonsOnly;
@property (nonatomic, readonly) NSObject <CcMediaDataSource> *dataSource;
@property (nonatomic, readonly) UIImage *disabledIcon;
@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) BOOL isEnabled;
@property (nonatomic, readonly) BOOL supportsImages;
@property (nonatomic, readonly) BOOL supportsVideo;
@property (nonatomic, readonly) NSString *title;

- (NSString *)titleWithSupportForImages:(BOOL)supportsImages video:(BOOL)supportsVideo;

@end
