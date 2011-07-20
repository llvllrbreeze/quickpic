#import "UploadManager.h"

#import "AppDelegate.h"
#import "Constants.h"
#import "UploadDelegate.h"


@interface UploadManager ()
  @property (nonatomic, retain) CcHttpRequest *request;
  @property (nonatomic, assign) UIBackgroundTaskIdentifier uploadInBackgroundTaskIdentifier;

  - (void)onRequestComplete:(CcHttpRequest *)request;
@end


@implementation UploadManager


@synthesize delegate;
@synthesize request;
@synthesize uploadInBackgroundTaskIdentifier;


#pragma mark Initialization


- (id)initWithMedia:(NSArray *)theMedia
      contacts:(NSArray *)theContacts
      url:(NSURL *)theUrl
      context:(NSString *)theContext {
  if (self = [super init]) {
    AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];
    CcSettings *settings = appDelegate.settings;
    
    contacts = [theContacts retain]; // Retaining, cleaning up in dealloc.
    media = [theMedia retain]; // Retaining, cleaning up in dealloc.
    
    BOOL thumbnailPhotos = [settings intValueForKey:@"pref.thumbnail-photos" defaultValue:NO];
    float maxImageSize = thumbnailPhotos ? THUMBNAIL_SIZE : 32767.0f;
    float maxImageWidth = maxImageSize;
    float maxImageHeight = maxImageSize;
    
    if (!CGSizeEqualToSize(appDelegate.maxImageSize, CGSizeZero)) {
      maxImageWidth = MIN(maxImageWidth, appDelegate.maxImageSize.width);
      maxImageHeight = MIN(maxImageWidth, appDelegate.maxImageSize.height);
    }
    
    for (CcMedia *mediaObj in media) {
      if (mediaObj.image) {
        CGSize mediaSize = mediaObj.image.size;
        if (mediaSize.width > maxImageWidth || mediaSize.height > maxImageHeight) {
          mediaObj.image = [mediaObj.image thumbnail:appDelegate.maxImageSize zoomAndCrop:NO];
        }
      }
    }
    
    url = [theUrl retain]; // Retaining, cleaning up in dealloc.
    context = [theContext retain]; // Retaining, cleaning up in dealloc.
  }
  return self;
}


#pragma mark Cleanup


- (void)dealloc {
  [contacts release];
  contacts = nil;

  [context release];
  context = nil;

  [media release];
  media = nil;

  [url release];
  url = nil;

  [super dealloc];
}


#pragma mark -


- (void)cancel {
  [self.request cancel];
  self.request = nil;

  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(start) object:nil];
}


- (void)start {
  [self.delegate uploadStarted:self]; 

  NSMutableArray *files = [NSMutableArray array];
  NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
      [NSString deviceKey], @"device_key",
      [UIDevice currentDevice].uniqueIdentifier, @"device_id",
      files, @"__files__", // This is inserted and then modified (since it's a reference, this is ok).
      context, @"context",
      nil];

  if ([contacts count]) {
    NSMutableArray *contactsForJson = [NSMutableArray arrayWithCapacity:[contacts count]];
    for (NSDictionary *personData in contacts) {
      NSMutableDictionary *personDataCopy =
          [NSMutableDictionary dictionaryWithDictionary:personData];

      [personDataCopy removeObjectForKey:@"id"];
      [personDataCopy removeObjectForKey:@"image"];

      [contactsForJson addObject:personDataCopy];
    }

    [data setValue:[contactsForJson JSONRepresentation] forKey:@"contacts"];
  }

  int fileIndex = 0;
  for (CcMedia *mediaObj in media) {
    NSData *mediaData = nil;
    NSString *contentType = nil;
    NSString *extension = nil;
    if (mediaObj.image) {
      mediaData = [UIImageJPEGRepresentation(mediaObj.image, IMAGE_QUALITY) retain]; // Retaining, cleaning up in dealloc.
      contentType = @"image/jpeg";
      extension = @"jpg";
    } else if (mediaObj.movieUrl) {
      mediaData = [NSData dataWithContentsOfURL:mediaObj.movieUrl];
      contentType = @"video/quicktime";
      extension = @"mov";
    } else {
      NSAssert(1, @"Programming Error: Received media without image or movieUrl!");
    }

    NSString *name = @"upload_file";
    if (fileIndex > 0) {
      name = [NSString stringWithFormat:@"upload_file_%d", fileIndex + 1];
    }

    NSString *filename = [NSString stringWithFormat:@"quickpic.%@", extension];
    if (fileIndex > 0) {
      filename = [NSString stringWithFormat:@"quickpic_%d.%@", fileIndex + 1, extension];
    }

    NSDictionary *file = [NSDictionary dictionaryWithObjectsAndKeys:
        name, @"name",
        filename, @"filename",
        contentType, @"content-type",
        mediaData, @"data",
        nil];
    [files addObject:file];

    NSString *sourceAuthorKey = @"source_author";
    NSString *sourceIdKey = @"source_id";
    NSString *sourceTypeKey = @"source_type";
    if (fileIndex > 0) {
      sourceAuthorKey = [NSString stringWithFormat:@"source_author_%d", fileIndex + 1];
      sourceIdKey = [NSString stringWithFormat:@"source_id_%d", fileIndex + 1];
      sourceTypeKey = [NSString stringWithFormat:@"source_type_%d", fileIndex + 1];
    }
    
    [data setValue:mediaObj.sourceAuthor forKey:sourceAuthorKey];
    [data setValue:mediaObj.sourceId forKey:sourceIdKey];
    [data setValue:mediaObj.sourceType forKey:sourceTypeKey];

    fileIndex++;
  }

  self.uploadInBackgroundTaskIdentifier =
      [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
  self.request = [CcHttpRequest requestUrl:url
                                method:@"POST(multipart/form-data)"
                                data:data];
  self.request.target = self;
  self.request.onError = @selector(onNetworkError:request:);
  self.request.onSuccess = @selector(onSuccess:data:target:);
  self.request.onProgress = @selector(onUploadData:progress:request:);
  [self.request send];
}


#pragma mark Private


- (void)onNetworkError:(NSError *)error request:(CcHttpRequest *)theRequest {
  CcSettings *settings = [CcAppDelegate instance].settings;
  BOOL developerMode = [settings intValueForKey:@"pref.developer-mode" defaultValue:0];

  if (developerMode) {
    NSDictionary *results = [NSDictionary dictionaryWithPlistData:theRequest.responseData];
    if (!results) {
      [CcUtils alert:@"The server didn't respond with a success plist as expected."
               title:@"Developer Tip"];
      NSLog(@"Server Response: %@", [NSString stringWithUtf8Data:theRequest.responseData]);
    }
  }

  if ([self.delegate upload:self errorOccurred:error]) {
    // Trying again in 10 seconds.
    [self performSelector:@selector(start) withObject:nil afterDelay:10.0f];
  }

  [self onRequestComplete:self.request];
}


- (void)onRequestComplete:(CcHttpRequest *)request {
  [[UIApplication sharedApplication] endBackgroundTask:self.uploadInBackgroundTaskIdentifier];
  self.request = nil;
}


- (void)onSuccess:(NSHTTPURLResponse *)response
        data:(NSData *)theData
        target:(CcHttpRequest *)target {
  NSError *error;
  [[GANTracker sharedTracker] trackEvent:@"quickpic"
                              action:@"upload-to-service"
                              label:[url host]
                              value:-1
                              withError:&error];

  NSDictionary *results = [NSDictionary dictionaryWithPlistData:theData];

  if (results && ![[results valueForKey:@"success"] boolValue]) {
    // In the event a plist was receipt with the success flag passed as false, treat as a failure.

    NSString *errorDetails = [results valueForKey:@"error_details"];
    if (errorDetails) {
      NSLog(@"%@", errorDetails);
    }
    
    [self onNetworkError:[NSError errorWithDomain:NSURLErrorDomain
                                  code:NSURLErrorDataNotAllowed
                                  userInfo:[results valueForKey:@"errormsg"]]
          request:self.request];
  }
  else {
    // If success

    AppDelegate *appDelegate = (AppDelegate *) [CcAppDelegate instance];
    appDelegate.postContext = results ?
        [results valueForKey:@"context" defaultValue:appDelegate.postContext] :
        appDelegate.postContext;

    [self.delegate uploadCompletedSuccessfully:self];

    [self onRequestComplete:self.request];
  }
}


- (void)onUploadData:(NSData *)data
        progress:(NSArray *)progress
        request:(CcHttpRequest *)request {
  [self.delegate upload:self progress:[[progress objectAtIndex:0] floatValue]];
}


@end
