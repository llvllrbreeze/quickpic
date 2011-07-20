#import "CcHttpRequest.h"

#import "CcAppDelegate.h"
#import "CcConfiguration.h"
#import "CcConstants.h"
#import "CcLocalCache.h"
#import "CcSettings.h"
#import "NSObject+cliqcliq.h"
#import "NSString+cliqcliq.h"
#import "NSURL+cliqcliq.h"


//#if defined(USE_DEV_SETTINGS) || defined(DISTRIBUTION_TEST)
  @implementation NSURLRequest (cliqcliq)


  + (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
  }


  @end
//#endif


static NSLock *lock = nil;
static int numOutstandingRequests = 0;
static NSMutableArray *requestQueue = nil;
static NSMutableDictionary *enqueuedGetRequests = nil;

void httpRequestStaticInitializer() {
  if (!lock) {
    lock = [[NSLock alloc] init];
  }
  
  if (!requestQueue) {
    requestQueue = [[NSMutableArray array] retain]; // Retaining, static.
  }

  if (!enqueuedGetRequests) {
    enqueuedGetRequests = [[NSMutableDictionary dictionary] retain]; // Retaining, static.
  }
}

@interface CcHttpRequest ()
  @property (nonatomic, retain, readwrite) NSHTTPURLResponse *response;

  + (void)checkRequestsQueue;
  - (void)closeConnection;
  + (NSString *)cookiePathForUrl:(NSURL *)url;
  - (void)enqueueRequest;
  - (NSArray *)getRelatedRequests:(BOOL)cleanup;
  - (void)openConnection;
  - (void)returnCachedData:(NSData *)cachedData;
@end


@implementation CcHttpRequest


@synthesize cacheDuration;
@synthesize data;
@synthesize identifier;
@synthesize onError;
@synthesize onProgress;
@synthesize onSuccess;
@synthesize response;
@synthesize responseData;
@synthesize target;


#pragma mark Initialization


- (id)initWithRequest:(NSURLRequest *)aRequest data:(NSDictionary *)theData {
  httpRequestStaticInitializer();

  if (self = [super init]) {
    data = [theData retain]; // Retaining, cleaning up in dealloc.
    request = [aRequest retain]; // Retaining, cleaning up in dealloc.
    responseData = [[NSMutableData data] retain]; // Retaining, cleaning up in dealloc.
  }
  return self;
}


#pragma mark Cleanup


- (void)dealloc {
  [data release];
  data = nil;

  [connection release];
  connection = nil;

  self.identifier = nil;

  [responseData release];
  responseData = nil;

  [request release];
  request = nil;
    
  self.response = nil;
    
  [target release];
  target = nil;

  [super dealloc];
}


#pragma mark URL Connection Event Handlers


// Final event, memory is cleaned up at the end of this.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  #ifdef DEBUG_HTTP_REQUESTS
    NSLog(@"Request for %@ failed!", [request URL]);
  #endif
  NSArray *requests = [self getRelatedRequests:YES];

  for (CcHttpRequest *httpRequest in requests) {
    if (httpRequest.target && httpRequest.onError) {
      [httpRequest.target performSelector:httpRequest.onError
                          withObject:error
                          withObject:httpRequest];
    }
  }
  [self closeConnection];
}


// Final event, memory is cleaned up at the end of this.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  #ifdef DEBUG_HTTP_REQUESTS
    NSLog(@"Request for %@ succeeded", [request URL]);
  #endif
  if (cacheDuration) {
    #ifdef DEBUG_HTTP_REQUESTS
      NSLog(@"Caching received data for: %@", [request URL]);
    #endif
    if ([self.response statusCode] == 200) {
      [CcLocalCache cacheData:responseData forUrl:[request URL] duration:cacheDuration];
    }
  }

  NSArray *requests = [self getRelatedRequests:YES];

  for (CcHttpRequest *httpRequest in requests) {
    if (httpRequest.target && httpRequest.onSuccess) {
      [httpRequest.target performSelector:httpRequest.onSuccess
                           withObject:self.response
                           withObject:responseData
                           withObject:httpRequest];
    }
  }
  [self closeConnection];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)newResponse {
  self.response = (NSHTTPURLResponse *) newResponse;

  NSString *newCookie = [[self.response allHeaderFields] valueForKey:@"Set-Cookie"];
  if (newCookie) {
    #ifdef DEBUG_HTTP_REQUESTS
      NSLog(@"Setting cookie: %@ for domain: %@", newCookie, [request URL]);
    #endif
    [CcHttpRequest setCookie:newCookie domain:[request URL]];
  }

  NSString *contentLengthString = [[self.response allHeaderFields] valueForKey:@"Content-Length"];
  if (contentLengthString) {
    contentLength = [contentLengthString intValue];
  }
}


- (void)connection:(NSURLConnection *)connection
        didReceiveData:(NSData *)newData {
  [responseData appendData:newData];

  if (contentLength) {
    receiveProgressPercent = [responseData length] / (float) contentLength;
  }

  NSArray *percentages = [NSArray arrayWithObjects:
      [NSNumber numberWithFloat:MAX(0.0f, MIN(0.999f, sendProgressPercent))],
      [NSNumber numberWithFloat:MAX(0.0f, MIN(0.999f, receiveProgressPercent))],
      nil];

  NSArray *requests = [self getRelatedRequests:NO];

  for (CcHttpRequest *httpRequest in requests) {
    if (httpRequest.target && httpRequest.onProgress) {
      [httpRequest.target performSelector:httpRequest.onProgress
                           withObject:responseData
                           withObject:percentages
                           withObject:httpRequest];
    }
  }
}


- (void)connection:(NSURLConnection *)connection
        didSendBodyData:(NSInteger)bytesWritten
        totalBytesWritten:(NSInteger)totalBytesWritten
        totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
  sendProgressPercent = totalBytesWritten / (float) totalBytesExpectedToWrite;

  NSArray *percentages = [NSArray arrayWithObjects:
      [NSNumber numberWithFloat:MAX(0.0f, MIN(0.999f, sendProgressPercent))],
      [NSNumber numberWithFloat:MAX(0.0f, MIN(0.999f, receiveProgressPercent))],
      nil];

  NSArray *requests = [self getRelatedRequests:NO];

  for (CcHttpRequest *httpRequest in requests) {
    if (httpRequest.target && httpRequest.onProgress) {
      [httpRequest.target performSelector:httpRequest.onProgress
                           withObject:responseData
                           withObject:percentages
                           withObject:httpRequest];
    }
  }
}


#pragma mark -


- (void)cancel {
  NSArray *requests = [self getRelatedRequests:YES];  

  for (CcHttpRequest *httpRequest in requests) {
    #ifdef DEBUG_HTTP_REQUESTS
      NSLog(@"Request for %@ cancelled", [httpRequest->request URL]);
    #endif

    httpRequest.onError = nil;
    httpRequest.onSuccess = nil;
    httpRequest.onProgress = nil;
    [httpRequest->connection cancel];

    [httpRequest closeConnection];
  }
}


+ (NSString *)encode:(NSDictionary *)data {
    if (!data) {
      return @"";
    }

    NSMutableString *bodyString = [NSMutableString stringWithString:@""];

    BOOL first = YES;
    for (NSString *key in [[data allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        if (!first) {
            [bodyString appendString:@"&"];
        }
        first = NO;

        NSString *valueString = [NSString stringWithFormat:@"%@", [data valueForKey:key]];
        NSString *dataString = [NSString stringWithFormat:@"%@=%@",
            [key stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
            [valueString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

        [bodyString appendString:dataString];
    }
    
    return bodyString;
}


+ (NSURLRequest *)prepareBasicRequestWithUrl:(NSURL *)url
                  method:(NSString *)method
                  data:(NSDictionary *)data {
  if ([method isEqualToString:@"GET"] && data) {
    url = [url addGetParameters:data];
  }

  #ifdef DEBUG_HTTP_REQUESTS
    NSLog(@"Requesting URL: %@", url);
  #endif

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

  NSString *cookie = [[CcAppDelegate instance].settings
                          stringValueForKey:[CcHttpRequest cookiePathForUrl:url]
                          defaultValue:nil];

  if (cookie) {
    [request addValue:cookie forHTTPHeaderField:@"Cookie"];
  }

  if ([method isEqualToString:@"GET"]) {
    [request setHTTPMethod:@"GET"];
  } else if ([method isEqualToString:@"POST"]) {
    // If a URL-encoded request.
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[[CcHttpRequest encode:data] dataUsingEncoding:NSUTF8StringEncoding]];
  } else if ([method isEqualToString:@"POST(multipart/form-data)"]) {
    // If a multipart/form-data request.
    
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------ClIqClIqmUlTiPaRtFoRm"; // TODO(westphal): randomize this
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",
                                                       boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSMutableData *body = [NSMutableData data];

    if (!data) {
      data = [NSDictionary dictionary];
    }
      
    for (NSString *key in data) {
      if ([key hasPrefix:@"__"]) {
        continue;
      }
      
      NSString *value = [data valueForKey:key];
      [body appendData:[NSString utf8DataWithFormat:
          @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",
          boundary,
          key,
          value]];
    }
          
    NSArray *files = [data valueForKey:@"__files__"];
    for (NSDictionary *file in files) {
        [body appendData:[NSString utf8DataWithFormat:@"--%@\r\n", boundary]];
        NSString *name = [file valueForKey:@"name"];
        NSString *filename = [file valueForKey:@"filename"];
        NSString *contentType = [file valueForKey:@"content-type"];
        if (!contentType) {
          contentType = @"application/octet-stream";
        }
        NSData *data = [file valueForKey:@"data"];
        if (filename) {
            [body appendData:[NSString utf8DataWithFormat:
                @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n",
                name,
                filename,
                contentType]];
        } else {
            [body appendData:[NSString utf8DataWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", name]];
        }
        [body appendData:data];
        [body appendData:[NSString utf8DataWithFormat:@"\r\n"]];
    }
      
    [body appendData:[NSString utf8DataWithFormat:@"--%@--\r\n", boundary]];

    [request setHTTPBody:body];
  }
  
  return request;
}


+ (CcHttpRequest *)requestUrl:(NSURL *)url method:(NSString *)method data:(NSDictionary *)data {
  NSURLRequest *request = [CcHttpRequest prepareBasicRequestWithUrl:url method:method data:data];
  return [[[CcHttpRequest alloc] initWithRequest:request data:data] autorelease];
}


- (void)send {
  [self retain];

  [self enqueueRequest];

  [CcHttpRequest checkRequestsQueue];
}


+ (void)setCookie:(NSString *)cookie domain:(NSURL *)url {
  CcSettings *settings = [CcAppDelegate instance].settings;

  NSString *cookiePath = [CcHttpRequest cookiePathForUrl:url];
  if (cookie) {
    [settings setStringValue:cookie forKey:cookiePath];
  } else {
    [settings removeValueForKey:cookiePath];
  }
}


#pragma mark Private


+ (void)checkRequestsQueue {
  CcHttpRequest *httpRequest = nil;

  @try {
    [lock lock];

    if (numOutstandingRequests < kCcHttpRequestMaxSimultaneousRequests && [requestQueue count]) {
      httpRequest = [requestQueue objectAtIndex:0];
      [requestQueue removeObjectAtIndex:0];

      numOutstandingRequests++;
    }
  } @finally {
    [lock unlock];
  }

  if (httpRequest) {
    [httpRequest openConnection];
  }
}


- (void)closeConnection {
  if (!releasedSelf) {
    [self release];
    releasedSelf = YES;
  }

  @try {
    [lock lock];

    [requestQueue removeObject:self];

    numOutstandingRequests--;
  } @finally {
    [lock unlock];
  }

  [CcHttpRequest checkRequestsQueue];
}


+ (NSString *)cookiePathForUrl:(NSURL *)url {
  return [NSString stringWithFormat:@"http-cookie:%@", [url host]];
}


- (void)enqueueRequest {
  @try {
    [lock lock];

    BOOL shouldEnqueue = YES;

    if ([[request HTTPMethod] isEqualToString:@"GET"]) {
      NSMutableArray *requests = [enqueuedGetRequests valueForKey:[[request URL] absoluteString]];
      shouldEnqueue = !requests;
      if (!requests) {
        requests = [NSMutableArray array];
        [enqueuedGetRequests setValue:requests forKey:[[request URL] absoluteString]];
      } else {
        #ifdef DEBUG_HTTP_REQUESTS
          NSLog(@"Sharing single GET request for URL: %@", [request URL]);
        #endif
      }
      [requests addObject:self];
    }

    if (shouldEnqueue) {
      [requestQueue addObject:self];
    }
  } @finally {
    [lock unlock];
  }
}


- (NSArray *)getRelatedRequests:(BOOL)cleanup {
  if ([[request HTTPMethod] isEqualToString:@"GET"]) {
    @try {
      [lock lock];

      NSString *urlString = [[request URL] absoluteString];
      NSArray *relatedRequests = [enqueuedGetRequests valueForKey:urlString];
      relatedRequests = [NSArray arrayWithArray:relatedRequests];

      if (cleanup) {
        [enqueuedGetRequests removeObjectForKey:urlString];
      }

      return relatedRequests;
    } @finally {
      [lock unlock];
    }
  } else {
    return [NSArray arrayWithObject:self];
  }
  
  return nil;
}


- (void)openConnection {
  if (cacheDuration) {
    NSData *cachedData = [CcLocalCache dataForUrl:[request URL] duration:cacheDuration];
    if (cachedData) {
      [self performSelector:@selector(returnCachedData:) withObject:cachedData afterDelay:0.0];
      return;
    }
  }

  connection = [[NSURLConnection connectionWithRequest:request delegate:self] retain]; // Retaining, cleaning up in dealloc.
}


- (void)returnCachedData:(NSData *)cachedData {
  #ifdef DEBUG_HTTP_REQUESTS
    NSLog(@"Using cached data for: %@", [request URL]);
  #endif
  NSArray *requests = [self getRelatedRequests:YES];

  for (CcHttpRequest *httpRequest in requests) {
    if (httpRequest.target && httpRequest.onSuccess) {
      [httpRequest.target performSelector:httpRequest.onSuccess
                           withObject:nil
                           withObject:cachedData
                           withObject:httpRequest];
    }
  }
  [self closeConnection];
  return;
}


@end
