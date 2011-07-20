#import <UIKit/UIKit.h>


@interface CcMedia : NSObject {
  UIImage *image;
  NSURL *movieUrl;
  NSString *sourceAuthor;
  NSString *sourceId;
  NSString *sourceType;
}

@property (nonatomic, readonly) UIImage *displayImage;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSURL *movieUrl;
@property (nonatomic, retain) NSString *sourceAuthor;
@property (nonatomic, retain) NSString *sourceId;
@property (nonatomic, retain) NSString *sourceType;

+ (CcMedia *)mediaWithImage:(UIImage *)anImage;
+ (CcMedia *)mediaWithImagePickerInfoDictionary:(NSDictionary *)info;
+ (CcMedia *)mediaWithMovieUrl:(NSURL *)aMovieUrl;
- (void)setSourceAuthor:(NSString *)aSourceAuthor
        sourceId:(NSString *)aSourceId
        sourceType:(NSString *)aSourceType;

@end
