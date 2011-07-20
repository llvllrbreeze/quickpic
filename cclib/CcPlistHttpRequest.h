#import <Foundation/Foundation.h>

#import "CcHttpRequest.h"


@interface CcPlistHttpRequest : CcHttpRequest {
@private
  SEL onRequestComplete;
  SEL originalOnError;
  SEL originalOnSuccess;
  SEL originalOnProgress;
  id originalTarget;
  BOOL useStandardErrorHandling;
}

@property (nonatomic, assign) SEL onRequestComplete;

- (id)initWithRequest:(NSURLRequest *)aRequest
      data:(NSDictionary *)theData
      useStandardErrorHandling:(BOOL)shouldUseStandardErrorHandling;
+ (CcPlistHttpRequest *)requestUrl:(NSURL *)url
                        method:(NSString *)method
                        data:(NSDictionary *)data
                        useStandardErrorHandling:(BOOL)useStandardErrorHandling;

@end
