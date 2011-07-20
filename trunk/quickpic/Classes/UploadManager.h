#import <cclib/Cclib.h>


@protocol UploadDelegate;


@interface UploadManager : NSObject {
  NSArray *contacts;
  NSString *context;
  NSObject <UploadDelegate> *delegate;
  NSArray *media;
  CcHttpRequest *request;
  UIBackgroundTaskIdentifier uploadInBackgroundTaskIdentifier;
  NSURL *url;
}

@property (nonatomic, assign) NSObject <UploadDelegate> *delegate;

- (void)cancel;
- (id)initWithMedia:(NSArray *)media
      contacts:(NSArray *)theContacts
      url:(NSURL *)theUrl
      context:(NSString *)theContext;
- (void)start;

@end
