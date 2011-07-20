#import "UIImageView+cliqcliq.h"


#import "CcConstants.h"
#import "CcHttpRequest.h"


@interface UIImageView ()
  - (void)onImageDownloadResponse:(NSHTTPURLResponse *)response
        data:(NSData *)data
        request:(CcHttpRequest *)request;
@end


@implementation UIImageView (cliqcliq)


- (CcHttpRequest *)setImageWithUrl:(NSURL *)url {
  CcHttpRequest *request = [CcHttpRequest requestUrl:url method:@"GET" data:nil];
  request.target = self;
  request.onSuccess = @selector(onImageDownloadResponse:data:request:);
  request.cacheDuration = kDurationImageCacheDefault;
  [request send];
  return request;
}


- (void)onImageDownloadResponse:(NSHTTPURLResponse *)response
        data:(NSData *)data
        request:(CcHttpRequest *)request {
  self.image = [UIImage imageWithData:data];
}


@end
