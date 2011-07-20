#import "CcMaskedImage.h"

#import "UIImage+cliqcliq.h"


@implementation CcMaskedImage


#pragma mark Initialization


- (id)initWithImage:(UIImage *)theImage mask:(UIImage *)theMask {
  if (self = [super init]) {
    self.opaque = NO;

    image = [[UIImage correctOrientation:theImage] retain]; // Retaining, cleaning up in dealloc.

    CGImageRef maskCgImage = theMask.CGImage;
    mask = CGImageMaskCreate(CGImageGetWidth(maskCgImage),
                             CGImageGetHeight(maskCgImage),
                             CGImageGetBitsPerComponent(maskCgImage),
                             CGImageGetBitsPerPixel(maskCgImage),
                             CGImageGetBytesPerRow(maskCgImage),
                             CGImageGetDataProvider(maskCgImage),
                             NULL,
                             NO);
    CGImageRetain(mask);
  }
  return self;
}


#pragma mark Cleanup


- (void)dealloc {
  [image release];
  image = nil;
  
  CGImageRelease(mask);
  mask = nil;

  [super dealloc];
}


#pragma mark Display {


- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextClearRect(context, rect);
  
  CGContextSaveGState(context);

  CGContextClipToMask(context, rect, mask);

  [image drawInRect:rect];

  CGContextRestoreGState(context);
}


@end
