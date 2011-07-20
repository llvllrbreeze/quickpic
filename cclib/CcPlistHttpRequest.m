#import "CcPlistHttpRequest.h"

#import "CcConstants.h"
#import "CcUtils.h"
#import "NSDictionary+cliqcliq.h"
#import "NSObject+cliqcliq.h"


@interface CcPlistHttpRequest ()
  - (void)onNetworkError:(NSError *)error request:(CcHttpRequest *)theRequest;
  - (void)onProgress:(NSData *)data
          percentages:(NSArray *)percentages
          request:(CcHttpRequest *)theRequest;
  - (void)onResponse:(NSHTTPURLResponse *)response
          data:(NSData *)data
          request:(CcHttpRequest *)theRequest;
@end


@implementation CcPlistHttpRequest


@synthesize onRequestComplete;


#pragma mark Initialization


- (id)initWithRequest:(NSURLRequest *)aRequest
      data:(NSDictionary *)theData
      useStandardErrorHandling:(BOOL)shouldUseStandardErrorHandling {
  useStandardErrorHandling = shouldUseStandardErrorHandling;
  
  self = [super initWithRequest:aRequest data:theData];
  [super setTarget:self];
  [super setOnError:@selector(onNetworkError:request:)];
  [super setOnSuccess:@selector(onResponse:data:request:)];
  [super setOnProgress:@selector(onProgress:percentages:request:)];
  return self;
}


#pragma mark Cleanup


- (void)dealloc {
  [originalTarget release];
  originalTarget = nil;

  [super dealloc];
}


#pragma mark -


+ (CcPlistHttpRequest *)requestUrl:(NSURL *)url
                        method:(NSString *)method
                        data:(NSDictionary *)data
                        useStandardErrorHandling:(BOOL)useStandardErrorHandling {
  if (!data) {
    data = [NSDictionary dictionary];
  }
  
  NSMutableDictionary *modifiedData = [NSMutableDictionary dictionaryWithDictionary:data];
  [modifiedData setValue:@"plist" forKey:@"enc"];

  NSURLRequest *request =
      [CcHttpRequest prepareBasicRequestWithUrl:url method:method data:modifiedData];

  return [[[CcPlistHttpRequest alloc] initWithRequest:request
                                      data:modifiedData
                                      useStandardErrorHandling:useStandardErrorHandling] autorelease];
}


- (void)setOnError:(SEL)onErrorSel {
  originalOnError = onErrorSel;
}


- (void)setOnProgress:(SEL)onProgressSel {
  originalOnProgress = onProgressSel;
}


- (void)setOnSuccess:(SEL)onSuccessSel {
  originalOnSuccess = onSuccessSel;
}


- (void)setTarget:(id)theTarget {
  originalTarget = theTarget;
}


#pragma mark Private


- (void)onNetworkError:(NSError *)error request:(CcHttpRequest *)theRequest {
  if (useStandardErrorHandling) {
    if ([error userInfo]) {
      id userInfo = [error userInfo];
      if ([userInfo isKindOfClass:[NSString class]]) {
        [CcUtils alert:(NSString *) [error userInfo]];
      } else {
        [CcUtils alert:[error localizedDescription]];
      }
    } else {
      [CcUtils alert:@"Unable to communicate with server"];
    }
  }

  if (originalOnError) {
    [originalTarget performSelector:originalOnError withObject:error withObject:theRequest];
  }

  if (onRequestComplete) {
    #ifdef DEBUG_SLOW_DOWN_NETWORK_REQUESTS
      [originalTarget performSelector:onRequestComplete
                      withObject:theRequest
                      afterDelay:4.0f];
    #else
      [originalTarget performSelector:onRequestComplete withObject:theRequest];
    #endif
  }
}


- (void)onProgress:(NSData *)data
        percentages:(NSArray *)percentages
        request:(CcHttpRequest *)theRequest {
  if (originalOnProgress) {
    [originalTarget performSelector:originalOnProgress
                    withObject:data
                    withObject:percentages
                    withObject:theRequest];
  }
}


- (void)onResponse:(NSHTTPURLResponse *)response
        data:(NSData *)data
        request:(CcHttpRequest *)theRequest {
  NSDictionary *results = [NSDictionary dictionaryWithPlistData:data];
  if (response && [response statusCode] != kHttpSuccess) {
    [self onNetworkError:[NSError errorWithDomain:NSURLErrorDomain
                                  code:NSURLErrorBadServerResponse
                                  userInfo:nil]
          request:theRequest];
    return;
  } else if (![[results valueForKey:@"success"] boolValue]) {
    NSString *errorDetails = [results valueForKey:@"error_details"];
    if (errorDetails) {
      NSLog(@"%@", errorDetails);
    }
    
    [self onNetworkError:[NSError errorWithDomain:NSURLErrorDomain
                                  code:NSURLErrorDataNotAllowed
                                  userInfo:[results valueForKey:@"errormsg"]]
          request:theRequest];
    return;
  }

  if (originalOnSuccess) {
    #ifdef DEBUG_SLOW_DOWN_NETWORK_REQUESTS
      [originalTarget performSelector:originalOnSuccess
                      withObject:response
                      withObject:data
                      withObject:theRequest
                      afterDelay:4.0f];
    #else
      [originalTarget performSelector:originalOnSuccess
                      withObject:response
                      withObject:data
                      withObject:theRequest];
    #endif
  }

  if (onRequestComplete) {
    #ifdef DEBUG_SLOW_DOWN_NETWORK_REQUESTS
      [originalTarget performSelector:onRequestComplete
                      withObject:theRequest
                      afterDelay:4.0f];
    #else
      [originalTarget performSelector:onRequestComplete withObject:theRequest];
    #endif
  }
}


@end
