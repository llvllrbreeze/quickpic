#import "CcFlickrPhotoDataSource.h"

#import "../CcConstants.h"
#import "../CcHttpRequest.h"
#import "../GANTracker.h"
#import "CcMedia.h"

#define MAX_IMAGES 160

@interface CcFlickrPhotoDataSource ()
  @property (nonatomic, retain) NSMutableDictionary *images;
  @property (nonatomic, retain) NSMutableArray *items;
  @property (nonatomic, retain) NSString *lastError;
  @property (nonatomic, retain) NSXMLParser *parser;
  @property (nonatomic, retain) NSString *query;
  
  - (void)onError:(NSString *)message target:(CcHttpRequest *)target;
  - (void)onProgress:(NSData *)data percentages:(NSArray *)percentages target:(CcHttpRequest *)target;
  - (void)onSuccess:(NSHTTPURLResponse *)response
          data:(NSData *)theData
          target:(CcHttpRequest *)target;
  - (void)requestSearchData;
  - (void)resetState;
  - (NSString *)urlStringForImageAtIndex:(int)index;
  - (NSString *)urlStringForThumbnailAtIndex:(int)index;
@end


@implementation CcFlickrPhotoDataSource


@synthesize creativeCommonsOnly;
@synthesize images;
@synthesize items;
@synthesize lastError;
@synthesize parser;
@synthesize query;


#pragma mark Initialization


- (id)init {
  if (self = [super init]) {
    httpRequests = [[NSMutableArray array] retain]; // Retaining, cleaning up in dealloc.

    [self requestSearchData];
  }
  return self;
}


#pragma mark Cleanup


- (void)dealloc {
  // Canceling any outstanding HTTP requests.
  [self cancel];

  [httpRequests release];
  httpRequests = nil;

  self.images = nil;
  self.items = nil;
  self.lastError = nil;

  [self.parser abortParsing];
  self.parser = nil;

  self.query = nil;

  [super dealloc];
}


#pragma mark CcMediaDataSource


- (void)cancel {
  for (CcHttpRequest *httpRequest in httpRequests) {
    [httpRequest cancel];
  }
  [httpRequests removeAllObjects];
}


- (NSString *)getLastError {
  return self.lastError;
}


- (NSString *)getTitle {
  return @"Flickr";
}


- (BOOL)hadError {
  return !!self.lastError;
}


- (CcMedia *)mediaAtIndex:(int)index {
  NSString *urlString = [self urlStringForImageAtIndex:index];

  if (![self mediaAtIndexIsReady:index]) {
    NSURL *url = [NSURL URLWithString:urlString];
    [self.images setValue:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]
                 forKey:urlString];
  }

  CcMedia *media = [CcMedia mediaWithImage:[self.images valueForKey:urlString]];
  [media setSourceAuthor:[self sourceAuthorForMediaAtIndex:index]
         sourceId:[self sourceIdForMediaAtIndex:index]
         sourceType:[self sourceTypeForMediaAtIndex:index]];
  return media;
}


- (BOOL)mediaAtIndexIsReady:(int)index {
  NSString *urlString = [self urlStringForImageAtIndex:index];
  
  return !![self.images valueForKey:urlString];
}


- (int)mediaCount {
  return [self.items count];
}


- (BOOL)isReady {
  return parsingCompletedSuccessfully;
}


- (BOOL)isSearchable {
  return YES;
}


- (int)mediaIdForMediaAtIndex:(int)index {
  return -1;
}


- (BOOL)requestMediaAtIndex:(int)index {
  BOOL readyImmediately = [self mediaAtIndexIsReady:index];
  
  if (!readyImmediately) {
    NSString *urlString = [self urlStringForImageAtIndex:index];
    NSURL *url = [NSURL URLWithString:urlString];

    NSArray *identifier =
        [NSArray arrayWithObjects:urlString, @"image", [NSNumber numberWithInt:index], nil];

    CcHttpRequest *request = [CcHttpRequest requestUrl:url method:@"GET" data:nil];
    request.target = self;
    request.identifier = identifier;
    request.onError = @selector(onError:target:);
    request.onSuccess = @selector(onSuccess:data:target:);
    request.onProgress = @selector(onProgress:percentages:target:);
    [request send];
    [httpRequests addObject:request];
  }
  
  return readyImmediately;
}


- (BOOL)requestThumbnailAtIndex:(int)index {
  BOOL readyImmediately = [self thumbnailAtIndexIsReady:index];
  
  if (!readyImmediately) {
    NSString *urlString = [self urlStringForThumbnailAtIndex:index];
    NSURL *url = [NSURL URLWithString:urlString];

    NSArray *identifier =
        [NSArray arrayWithObjects:urlString, @"thumbnail", [NSNumber numberWithInt:index], nil];

    CcHttpRequest *request = [CcHttpRequest requestUrl:url method:@"GET" data:nil];
    request.target = self;
    request.identifier = identifier;
    request.onError = @selector(onError:target:);
    request.onSuccess = @selector(onSuccess:data:target:);
    request.onProgress = @selector(onProgress:percentages:target:);
    request.cacheDuration = kDurationImageCacheDefault;
    [request send];
    [httpRequests addObject:request];
  }
  
  return readyImmediately;
}


- (void)setSearchQuery:(NSString *)aQuery {
  [self resetState];
  self.query = aQuery;

  [self requestSearchData];
}


- (NSString *)sourceAuthorForMediaAtIndex:(int)index {
  NSDictionary *item = [self.items objectAtIndex:index];
  return [item valueForKey:@"ownername"];
}


- (NSString *)sourceIdForMediaAtIndex:(int)index {
  NSDictionary *item = [self.items objectAtIndex:index];
  NSString *photoId = [item valueForKey:@"id"];
  NSString *ownerId = [item valueForKey:@"owner"];
  NSString *username = [item valueForKey:@"pathalias"];

  NSString *path = [username isEqualToString:@""] ? ownerId : username;

  return [NSString stringWithFormat:@"http://www.flickr.com/photos/%@/%@/", path, photoId];
}


- (NSString *)sourceTypeForMediaAtIndex:(int)index {
  return @"flickr";
}


- (UIImage *)thumbnailAtIndex:(int)index {
  NSString *urlString = [self urlStringForThumbnailAtIndex:index];

  if (![self thumbnailAtIndexIsReady:index]) {
    NSURL *url = [NSURL URLWithString:urlString];
    [self.images setValue:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]]
                 forKey:urlString];
  }

  return [self.images valueForKey:urlString];
}


- (BOOL)thumbnailAtIndexIsReady:(int)index {
  NSString *urlString = [self urlStringForThumbnailAtIndex:index];
  
  return !![self.images valueForKey:urlString];
}


#pragma mark CcMediaPickerPlugin


- (NSObject <CcMediaDataSource> *)dataSource {
  return self;
}


- (UIImage *)disabledIcon {
  return nil;
}


- (UIImage *)icon {
  return [UIImage imageNamed:@"buttonIcon_flickr.png"];
}


- (BOOL)isEnabled {
  return YES;
}


- (BOOL)supportsImages {
  return YES;
}


- (BOOL)supportsVideo {
  return NO;
}


- (NSString *)title {
  return @"Flickr";
}


- (NSString *)titleWithSupportForImages:(BOOL)supportsImages video:(BOOL)supportsVideo {
  return @"Flickr Photos";
}


#pragma mark NSXMLParser delegate


- (void)parserDidEndDocument:(NSXMLParser *)parser {
  self.parser = nil;

  parsingCompletedSuccessfully = YES;

  [self notifyMediaDataAvailabilityChanged];
}


- (void)parser:(NSXMLParser *)parser
       didStartElement:(NSString *)elementName
       namespaceURI:(NSString *)namespaceURI
       qualifiedName:(NSString *)qualifiedName
       attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"photo"]) {
    [self.items addObject:attributeDict];
  }
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
  [self.parser abortParsing];
  self.parser = nil;
  
  self.lastError = [parseError localizedDescription];

  [self notifyMediaDataAvailabilityChanged];
}


#pragma mark -


- (void)onError:(NSString *)message target:(CcHttpRequest *)target {
  [httpRequests removeObject:target];

  NSArray *identifier = target.identifier;

  if (!identifier) {
    self.lastError = message;

    [self notifyMediaDataAvailabilityChanged];
  } else {
    NSString *type = [identifier objectAtIndex:1];
    int imageIndex = [[identifier objectAtIndex:2] intValue];

    if ([type isEqualToString:@"image"]) {
      [self notifyMediaProgressChanged:-1.0f mediaIndex:imageIndex];
    } else {
      [self notifyThumbnailProgressChanged:-1.0f mediaIndex:imageIndex];
    }
  }
}


- (void)onProgress:(NSData *)data
        percentages:(NSArray *)percentages
        target:(CcHttpRequest *)target {
  NSArray *identifier = target.identifier;

  float downloadPercent = [[percentages objectAtIndex:1] floatValue];

  if (!identifier) {
    [self notifyInitialProgressChanged:downloadPercent];
  } else {
    NSString *type = [identifier objectAtIndex:1];
    int imageIndex = [[identifier objectAtIndex:2] intValue];

    if ([type isEqualToString:@"image"]) {
      [self notifyMediaProgressChanged:downloadPercent mediaIndex:imageIndex];
    } else {
      [self notifyThumbnailProgressChanged:downloadPercent mediaIndex:imageIndex];
    }
  }
}


- (void)onSuccess:(NSHTTPURLResponse *)response
        data:(NSData *)theData
        target:(CcHttpRequest *)target {
  [httpRequests removeObject:target];

  NSArray *identifier = target.identifier;

  if (!identifier) {
    self.items = [NSMutableArray arrayWithCapacity:MAX_IMAGES];
    self.images = [NSMutableDictionary dictionaryWithCapacity:MAX_IMAGES];
    
    self.parser = [[[NSXMLParser alloc] initWithData:theData] autorelease];
    [self.parser setDelegate:self];
    [self.parser parse];
  } else {
    NSString *urlString = [identifier objectAtIndex:0];
    NSString *type = [identifier objectAtIndex:1];
    int imageIndex = [[identifier objectAtIndex:2] intValue];

    UIImage *image = [UIImage imageWithData:theData];
    [self.images setValue:image forKey:urlString];

    if ([type isEqualToString:@"image"]) {
      [self notifyMediaProgressChanged:1.0f mediaIndex:imageIndex];
    } else {
      [self notifyThumbnailProgressChanged:1.0f mediaIndex:imageIndex];
    }
  }
}


- (void)requestSearchData {
  NSError *error;
  [[GANTracker sharedTracker] trackEvent:@"media-picker"
                              action:@"flickr-photo-search"
                              label:@""
                              value:-1
                              withError:&error];

  NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
      @"a6938fb5b892c17b5f30a1a3bb780b1e", @"api_key",
      @"flickr.photos.search", @"method",
      @"rest", @"format",
      @"1", @"safe_search",
      @"7", @"content_type",
      @"photos", @"media",
      @"owner_name,path_alias", @"extras",
      [NSNumber numberWithInt:MAX_IMAGES], @"per_page",
      nil];

  if ([self.query length]) {
    [data setValue:self.query forKey:@"text"];
    [data setValue:@"relevance" forKey:@"sort"];
  } else {
    [data setValue:@"interestingness-desc" forKey:@"sort"];
  }

  if (self.creativeCommonsOnly) {
    [data setValue:@"4,2,1,5,7" forKey:@"license"];
  }

  CcHttpRequest *request = [CcHttpRequest
      requestUrl:[NSURL URLWithString:@"http://api.flickr.com/services/rest/"]
      method:@"GET"
      data:data];
  request.target = self;
  request.onError = @selector(onError:target:);
  request.onSuccess = @selector(onSuccess:data:target:);
  request.onProgress = @selector(onProgress:percentages:target:);
  request.cacheDuration = kDurationFlickrSearchResultsCache;
  [request send];
  [httpRequests addObject:request];
}


- (void)resetState {
  for (CcHttpRequest *request in httpRequests) {
    [request cancel];
  }
  [httpRequests removeAllObjects];

  [images removeAllObjects];
  [items removeAllObjects];
  self.lastError = nil;
  self.parser = nil;
  parsingCompletedSuccessfully = NO;
  self.query = nil;
}


- (NSString *)urlStringForImageAtIndex:(int)index {
  NSDictionary *item = [self.items objectAtIndex:index];

  return [NSString stringWithFormat:
      @"http://farm%@.static.flickr.com/%@/%@_%@.jpg",
      [item valueForKey:@"farm"],
      [item valueForKey:@"server"],
      [item valueForKey:@"id"],
      [item valueForKey:@"secret"]];
}


- (NSString *)urlStringForThumbnailAtIndex:(int)index {
  NSDictionary *item = [self.items objectAtIndex:index];

  return [NSString stringWithFormat:
      @"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg",
      [item valueForKey:@"farm"],
      [item valueForKey:@"server"],
      [item valueForKey:@"id"],
      [item valueForKey:@"secret"]];
}


@end
