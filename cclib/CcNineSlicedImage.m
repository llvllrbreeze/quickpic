#import "CcNineSlicedImage.h"


@interface CcNineSlicedImage ()
  - (void)updateSliceImages;
@end


@implementation CcNineSlicedImage


@synthesize image;


#pragma mark Initialization


- (id)initWithFrame:(CGRect)frame image:(UIImage *)sliceableImage centerSlice:(CGRect)slice {
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        centerSlice = slice;
        self.image = sliceableImage;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth + UIViewAutoresizingFlexibleHeight;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}


#pragma mark Cleanup


- (void)dealloc {
  self.image = nil;
  
  [sliceImages release];
  sliceImages = nil;
  
  [super dealloc];
}


#pragma mark Display


- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextClearRect(context, rect);
  
  CGContextSaveGState(context);

  int frameWidth = self.frame.size.width;
  int frameHeight = self.frame.size.height;

  int leftWidth = centerSlice.origin.x;
  int rightWidth = self.image.size.width - (leftWidth + centerSlice.size.width);
  int centerWidth = frameWidth - leftWidth - rightWidth;

  int topHeight = centerSlice.origin.y;
  int bottomHeight = self.image.size.height - (topHeight + centerSlice.size.height);
  int middleHeight = frameHeight - topHeight - bottomHeight;

	CGContextScaleCTM(context, 1.0, -1.0);

  UIImage *tempImage;
  int topOffset;

  int rightOffset = frameWidth - rightWidth;

  topOffset = 0;

  // Top-left
  tempImage = [sliceImages objectAtIndex:0];
  if (![tempImage isKindOfClass:[NSNull class]]) {
    CGContextDrawImage(context, CGRectMake(0, topOffset, leftWidth, -topHeight), tempImage.CGImage);
  }

  // Top-center
  tempImage = [sliceImages objectAtIndex:1];
  if (![tempImage isKindOfClass:[NSNull class]]) {
    CGContextDrawImage(context,
                       CGRectMake(leftWidth, topOffset, centerWidth, -topHeight),
                       tempImage.CGImage);
  }

  // Top-right
  tempImage = [sliceImages objectAtIndex:2];
  if (![tempImage isKindOfClass:[NSNull class]]) {
    CGContextDrawImage(context,
                       CGRectMake(rightOffset, topOffset, rightWidth, -topHeight),
                       tempImage.CGImage);
  }

  topOffset = -topHeight;

  // Middle-left
  tempImage = [sliceImages objectAtIndex:3];
  if (![tempImage isKindOfClass:[NSNull class]]) {
    CGContextDrawImage(context,
                       CGRectMake(0, topOffset, leftWidth, -middleHeight), tempImage.CGImage);
  }

  // Middle-center
  tempImage = [sliceImages objectAtIndex:4];
  if (![tempImage isKindOfClass:[NSNull class]]) {
    CGContextDrawImage(context,
                       CGRectMake(leftWidth, topOffset, centerWidth, -middleHeight),
                       tempImage.CGImage);
  }

  // Middle-right
  tempImage = [sliceImages objectAtIndex:5];
  if (![tempImage isKindOfClass:[NSNull class]]) {
    CGContextDrawImage(context,
                       CGRectMake(rightOffset, topOffset, rightWidth, -middleHeight),
                       tempImage.CGImage);
  }

  topOffset = -(frameHeight - bottomHeight);

  // Bottom-left
  tempImage = [sliceImages objectAtIndex:6];
  if (![tempImage isKindOfClass:[NSNull class]]) {
    CGContextDrawImage(context,
                       CGRectMake(0, topOffset, leftWidth, -bottomHeight),
                       tempImage.CGImage);
  }

  // Bottom-center
  tempImage = [sliceImages objectAtIndex:7];
  if (![tempImage isKindOfClass:[NSNull class]]) {
    CGContextDrawImage(context,
                       CGRectMake(leftWidth, topOffset, centerWidth, -bottomHeight),
                       tempImage.CGImage);
  }

  // Bottom-right
  tempImage = [sliceImages objectAtIndex:8];
  if (![tempImage isKindOfClass:[NSNull class]]) {
    CGContextDrawImage(context,
                       CGRectMake(rightOffset, topOffset, rightWidth, -bottomHeight),
                       tempImage.CGImage);
  }

  CGContextRestoreGState(context);
}


#pragma mark -


- (void)setCenterSlice:(CGRect)slice {
  centerSlice = slice;
  [self updateSliceImages];
  [self setNeedsDisplay];
}


- (void)setImage:(UIImage *)sliceableImage {
  [image release];
  image = sliceableImage;
  [image retain];
  [self updateSliceImages];
  [self setNeedsDisplay];
}


- (void)updateSliceImages {
  [sliceImages release];
  sliceImages = nil;

  if (!self.image) {
    return;
  }

  int imageWidth = self.image.size.width;
  int imageHeight = self.image.size.height;

  int leftWidth = centerSlice.origin.x;
  int centerWidth = centerSlice.size.width;
  int centerRight = centerSlice.origin.x + centerWidth;
  int rightWidth = self.image.size.width - centerRight;

  int topHeight = centerSlice.origin.y;
  int middleHeight = centerSlice.size.height;
  int middleBottom = centerSlice.origin.y + middleHeight;
  int bottomHeight = self.image.size.height - middleBottom;

  sliceImages = [[NSMutableArray arrayWithCapacity:9] retain];

  UIImage *tempImage;

  // Top-left
  if (leftWidth > 0 && topHeight > 0) {
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.image.CGImage,
                                                       CGRectMake(0, 0, leftWidth, topHeight));
    tempImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    [sliceImages addObject:tempImage];
  } else {
    [sliceImages addObject:[NSNull null]];
  }

  // Top-center
  if (centerWidth > 0 && topHeight > 0) {
    CGImageRef imageRef = CGImageCreateWithImageInRect(
        self.image.CGImage,
        CGRectMake(leftWidth, 0, centerWidth, topHeight));
    tempImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    [sliceImages addObject:tempImage];
  } else {
    [sliceImages addObject:[NSNull null]];
  }

  // Top-right
  if (rightWidth > 0 && topHeight > 0) {
    CGImageRef imageRef = CGImageCreateWithImageInRect(
        self.image.CGImage,
        CGRectMake(imageWidth - rightWidth, 0, rightWidth, topHeight));
    tempImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    [sliceImages addObject:tempImage];
  } else {
    [sliceImages addObject:[NSNull null]];
  }

  // Middle-left
  if (leftWidth > 0 && middleHeight > 0) {
    CGImageRef imageRef = CGImageCreateWithImageInRect(
        self.image.CGImage,
        CGRectMake(0, topHeight, leftWidth, middleHeight));
    tempImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    [sliceImages addObject:tempImage];
  } else {
    [sliceImages addObject:[NSNull null]];
  }

  // Middle-center
  if (centerWidth > 0 && middleHeight > 0) {
    CGImageRef imageRef = CGImageCreateWithImageInRect(
        self.image.CGImage,
        CGRectMake(leftWidth, topHeight, centerWidth, middleHeight));
    tempImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    [sliceImages addObject:tempImage];
  } else {
    [sliceImages addObject:[NSNull null]];
  }

  // Middle-right
  if (rightWidth > 0 && middleHeight > 0) {
    CGImageRef imageRef = CGImageCreateWithImageInRect(
        self.image.CGImage,
        CGRectMake(imageWidth - rightWidth, topHeight, rightWidth, middleHeight));
    tempImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    [sliceImages addObject:tempImage];
  } else {
    [sliceImages addObject:[NSNull null]];
  }

  // Bottom-left
  if (leftWidth > 0 && bottomHeight > 0) {
    CGImageRef imageRef = CGImageCreateWithImageInRect(
        self.image.CGImage,
        CGRectMake(0, imageHeight - bottomHeight, leftWidth, bottomHeight));
    tempImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    [sliceImages addObject:tempImage];
  } else {
    [sliceImages addObject:[NSNull null]];
  }

  // Bottom-center
  if (centerWidth > 0 && bottomHeight > 0) {
    CGImageRef imageRef = CGImageCreateWithImageInRect(
        self.image.CGImage,
        CGRectMake(leftWidth, imageHeight - bottomHeight, centerWidth, bottomHeight));
    tempImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    [sliceImages addObject:tempImage];
  } else {
    [sliceImages addObject:[NSNull null]];
  }

  // Bottom-right
  if (rightWidth > 0 && bottomHeight > 0) {
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.image.CGImage,
                                                       CGRectMake(imageWidth - rightWidth,
                                                                  imageHeight - bottomHeight,
                                                                  rightWidth,
                                                                  bottomHeight));
    tempImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    [sliceImages addObject:tempImage];
  } else {
    [sliceImages addObject:[NSNull null]];
  }
}


@end
