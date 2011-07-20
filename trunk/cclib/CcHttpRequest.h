#import <Foundation/Foundation.h>

#import "CcConfiguration.h"


static const int kCcHttpRequestMaxSimultaneousRequests = 4;


//#if defined(USE_DEV_SETTINGS) || defined(DISTRIBUTION_TEST)
  @interface NSURLRequest (cliqcliq)
    + (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;
  @end
//#endif


@interface CcHttpRequest : NSObject {
@private
  int cacheDuration;
  NSURLConnection *connection;
  int contentLength;
  NSDictionary *data;
  id identifier;
  SEL onError;
  SEL onSuccess;
  SEL onProgress;
  float receiveProgressPercent;
  BOOL releasedSelf;
  NSURLRequest *request;
  NSHTTPURLResponse *response;
  NSMutableData *responseData;
  float sendProgressPercent;
  id target;
}

@property (nonatomic, assign) int cacheDuration;
@property (nonatomic, readonly) NSDictionary *data;
@property (nonatomic, retain) id identifier;
@property (nonatomic, assign) SEL onError;
@property (nonatomic, assign) SEL onProgress;
@property (nonatomic, assign) SEL onSuccess;
@property (nonatomic, retain, readonly) NSHTTPURLResponse *response;
@property (nonatomic, retain, readonly) NSData *responseData;
@property (nonatomic, retain) id target;

- (void)cancel;
+ (NSString *)encode:(NSDictionary *)data;
- (id)initWithRequest:(NSURLRequest *)aRequest data:(NSDictionary *)theData;
+ (NSURLRequest *)prepareBasicRequestWithUrl:(NSURL *)url
                  method:(NSString *)method
                  data:(NSDictionary *)data;

/**
 * @param onError a selector that takes two parameters: 1.) (NSError *) the error, 2.)
 *        (CcHttpRequest *) the request object.
 * @param onSuccess a selector that takes three parameters: 1.) (NSHTTPURLResponse *) the response
 *        object, 2.) (NSData *) the received data, 3.) (CcHttpRequest *) the request object.
 * @param onProgress a selector that takes three parameters: 1.) (NSData *) the data received so
 *        far, 2.) (NSArray *) an array of percentages with exactly two elements: send progress and
 *        receive progress, 3.) (CcHttpRequest *) the request object.
 */
+ (CcHttpRequest *)requestUrl:(NSURL *)url method:(NSString *)method data:(NSDictionary *)data;

- (void)send;
+ (void)setCookie:(NSString *)cookie domain:(NSURL *)url;

@end
