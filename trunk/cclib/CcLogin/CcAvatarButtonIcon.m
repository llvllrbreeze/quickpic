#import "CcAvatarButtonIcon.h"

#import "../CcMaskedImage.h"


@interface CcAvatarButtonIcon ()
  @property (nonatomic, retain) CcMaskedImage *maskedAvatar;
  - (void)customInitialization;
@end


@implementation CcAvatarButtonIcon


@synthesize maskedAvatar;


#pragma mark Initialization


- (id)init {
  if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 34.0f, 34.0f)]) {
    [self customInitialization];
  }
  return self;
}


- (void)awakeFromNib {
  [self customInitialization];

  [super awakeFromNib];
}


- (void)customInitialization {
  highlight = [[UIImageView alloc] initWithImage:
                   [UIImage imageNamed:@"avatarButtonIcon_highlight.png"]]; // Not auto-releasing, cleaning up in dealloc.
  shadow = [[UIImageView alloc] initWithImage:
                [UIImage imageNamed:@"avatarButtonIcon_shadow.png"]]; // Not auto-releasing, cleaning up in dealloc.
  
  [self addSubview:shadow];
  [self addSubview:highlight];

  [self setAvatar:nil];
}


#pragma mark Cleanup


- (void)dealloc {
  self.maskedAvatar = nil;
  
  [highlight release];
  highlight = nil;
  
  [shadow release];
  shadow = nil;

  [super dealloc];
}


#pragma mark -


- (void)setAvatar:(UIImage *)image {
  if (!image) {
    image = [UIImage imageNamed:@"defaultAvatar_small.png"];
  }

  [self.maskedAvatar removeFromSuperview];
  
  self.maskedAvatar = [[[CcMaskedImage alloc]
                           initWithImage:image
                           mask:[UIImage imageNamed:@"avatarButtonIcon_mask.png"]] autorelease];
  self.maskedAvatar.frame = CGRectMake(1.0f, 0.0f, 32.0f, 32.0f);
  [self insertSubview:self.maskedAvatar belowSubview:highlight];
}


@end
