#import "UploadManager.h"


@protocol UploadDelegate

- (void)uploadCompletedSuccessfully:(UploadManager *)sender;
- (BOOL)upload:(UploadManager *)sender errorOccurred:(NSError *)error;
- (void)upload:(UploadManager *)sender progress:(float)progress;
- (void)uploadStarted:(UploadManager *)sender;

@end
