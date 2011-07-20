#import "CcMedia.h"

#import "../UIImage+cliqcliq.h"
#import "CcMediaPicker.h"


@implementation CcMedia


@synthesize image;
@synthesize movieUrl;
@synthesize sourceAuthor;
@synthesize sourceId;
@synthesize sourceType;


#pragma mark Cleanup


- (void)dealloc {
  self.image = nil;
  self.movieUrl = nil;
  self.sourceAuthor = nil;
  self.sourceId = nil;
  self.sourceType = nil;

  [super dealloc];
}


#pragma mark -


- (UIImage *)displayImage {
  return self.image ? self.image : [UIImage posterImageForMovieWithFileUrl:self.movieUrl];
}


+ (CcMedia *)mediaWithImage:(UIImage *)anImage {
  CcMedia *output = [[[CcMedia alloc] init] autorelease];
  output.image = anImage;
  return output;
}


+ (CcMedia *)mediaWithImagePickerInfoDictionary:(NSDictionary *)info {
  CcMedia *output = [[[CcMedia alloc] init] autorelease];

  NSString *mediaType = [info valueForKey:UIImagePickerControllerMediaType];
  if ([mediaType isEqualToString:kUTTypeImage]) {
    output.image = [info valueForKey:UIImagePickerControllerEditedImage];

    if (!output.image) {
      output.image = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
  } else if ([mediaType isEqualToString:kUTTypeMovie]) {
    output.movieUrl = [info valueForKey:UIImagePickerControllerMediaURL];
  } else {
    return nil;
  }

  return output;
}


+ (CcMedia *)mediaWithMovieUrl:(NSURL *)aMovieUrl {
  CcMedia *output = [[[CcMedia alloc] init] autorelease];
  output.movieUrl = aMovieUrl;
  return output;
}


- (void)setSourceAuthor:(NSString *)aSourceAuthor
        sourceId:(NSString *)aSourceId
        sourceType:(NSString *)aSourceType {
  self.sourceAuthor = aSourceAuthor;
  self.sourceId = aSourceId;
  self.sourceType = aSourceType;
}


@end
