#import "UIImage+cliqcliq.h"

#import "CcConstants.h"
#import "CcHttpRequest.h"
#import "CcLocalCache.h"


@implementation UIImage (cliqcliq)


// Based on http://discussions.apple.com/thread.jspa?threadID=1537011
+ (UIImage *)correctOrientation:(UIImage *)image {
  CGImageRef imgRef = image.CGImage;

  CGFloat width = CGImageGetWidth(imgRef);
  CGFloat height = CGImageGetHeight(imgRef);

  CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
  
  UIImageOrientation orient = image.imageOrientation;
  switch(orient) {
  case UIImageOrientationUp: //EXIF = 1
      transform = CGAffineTransformIdentity;
      break;
    
  case UIImageOrientationUpMirrored: //EXIF = 2
      transform = CGAffineTransformMakeTranslation(width, 0.0);
      transform = CGAffineTransformScale(transform, -1.0, 1.0);
      break;
    
  case UIImageOrientationDown: //EXIF = 3
      transform = CGAffineTransformMakeTranslation(width, height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
    
  case UIImageOrientationDownMirrored: //EXIF = 4
      transform = CGAffineTransformMakeTranslation(0.0, height);
      transform = CGAffineTransformScale(transform, 1.0, -1.0);
      break;
    
  case UIImageOrientationLeftMirrored: //EXIF = 5
      bounds.size.height = width;
      bounds.size.width = height;
      transform = CGAffineTransformMakeTranslation(height, width);
      transform = CGAffineTransformScale(transform, -1.0, 1.0);
      transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
      break;
    
  case UIImageOrientationLeft: //EXIF = 6
      bounds.size.height = width;
      bounds.size.width = height;
      transform = CGAffineTransformMakeTranslation(0.0, width);
      transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
      break;
    
  case UIImageOrientationRightMirrored: //EXIF = 7
      bounds.size.height = width;
      bounds.size.width = height;
      transform = CGAffineTransformMakeScale(-1.0, 1.0);
      transform = CGAffineTransformRotate(transform, M_PI / 2.0);
      break;
    
  case UIImageOrientationRight: //EXIF = 8
      bounds.size.height = width;
      bounds.size.width = height;
      transform = CGAffineTransformMakeTranslation(height, 0.0);
      transform = CGAffineTransformRotate(transform, M_PI / 2.0);
      break;
    
  default:
      [NSException raise:NSInternalInconsistencyException
                   format:@"Invalid image orientation"];
  }

  UIGraphicsBeginImageContext(bounds.size);

  CGContextRef context = UIGraphicsGetCurrentContext();

  if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -1.0, 1.0);
		CGContextTranslateCTM(context, -height, 0);
	} else {
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);

  UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return imageCopy;
}


+ (UIImage *)flipVertically:(UIImage *)image {
  CGImageRef imgRef = image.CGImage;

  CGFloat width = CGImageGetWidth(imgRef);
  CGFloat height = CGImageGetHeight(imgRef);

  CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
  
  UIImageOrientation orient = image.imageOrientation;
  transform = CGAffineTransformMakeTranslation(0.0, height);
  transform = CGAffineTransformScale(transform, 1.0, -1.0);

  UIGraphicsBeginImageContext(bounds.size);

  CGContextRef context = UIGraphicsGetCurrentContext();

  if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -1.0, 1.0);
		CGContextTranslateCTM(context, -height, 0);
	} else {
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);

  UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return imageCopy;
}


+ (CcHttpRequest *)loadImageWithUrl:(NSURL *)url target:(NSObject *)target set:(SEL)setSelector {
  NSData *cachedImageData = [CcLocalCache dataForUrl:url duration:kTimeOneDayInSeconds];
  if (cachedImageData) {
    UIImage *image = [UIImage imageWithData:cachedImageData];
    [target performSelector:setSelector withObject:image];
    return nil;
  }

  NSArray *identifier = [NSArray arrayWithObjects:target, NSStringFromSelector(setSelector), nil];
  CcHttpRequest *request = [CcHttpRequest requestUrl:url method:@"GET" data:nil];
  request.target = self;
  request.identifier = identifier;
  request.onSuccess = @selector(onImageDownloadResponse:data:request:);
  request.cacheDuration = kDurationImageCacheDefault;
  [request send];
  return request;
}


+ (void)onImageDownloadResponse:(NSHTTPURLResponse *)response
        data:(NSData *)data
        request:(CcHttpRequest *)request {
  UIImage *image = [UIImage imageWithData:data];

  NSArray *identifier = request.identifier;
  NSObject *target = [identifier objectAtIndex:0];
  SEL setSelector = NSSelectorFromString([identifier objectAtIndex:1]);

  [target performSelector:setSelector withObject:image];
}


+ (UIImage *)posterImageForMovieWithFileUrl:(NSURL *)url {
  // TODO(westphal): This is a placeholder solution until a better one comes along.
  return [UIImage imageNamed:@"genericMoviePosterImage.png"];
}


- (UIImage *)thumbnail:(CGSize)size {
  return [self thumbnail:size zoomAndCrop:YES];
}


- (UIImage *)thumbnail:(CGSize)size zoomAndCrop:(BOOL)zoomAndCrop {
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  void *rawImageBuffer = malloc(size.width * size.height * 4);
  if (!rawImageBuffer) {
    return nil;
  }
  
  if (!zoomAndCrop) {
    float hRatio = size.width / self.size.width;
    float vRatio = size.height / self.size.height;
    float ratio = MIN(hRatio, vRatio);
    if (ratio >= 1.0f) {
      return self;
    } else {
      size = CGSizeMake((int) (self.size.width * ratio), (int) (self.size.height * ratio));
    }
  }
  
  CGContextRef context = CGBitmapContextCreate(rawImageBuffer,
                                               size.width,
                                               size.height,
                                               8,
                                               size.width * 4,
                                               colorSpace, kCGImageAlphaPremultipliedFirst);
  CGContextSetAllowsAntialiasing(context, YES);
  CGContextSetShouldAntialias(context, YES);
  CGColorSpaceRelease(colorSpace);
  
  if (zoomAndCrop) {
    float x = 0;
    float width = size.width;
    float height = self.size.height * (size.width / self.size.width);
    float y = (size.height - height) / 2.0f;
    if (height < size.height) {
      y = 0;
      height = size.height;
      width = self.size.width * (size.height / self.size.height);
      x = (size.width - width) / 2.0f;
    }
    
    CGContextDrawImage(context, CGRectMake(x, y, width, height), self.CGImage);
  } else {
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
  }
  
  UIImage *output = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];

  CGContextRelease(context);
  free(rawImageBuffer);
  
  return output;
}


@end
