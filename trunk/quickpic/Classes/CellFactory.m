#import "CellFactory.h"

#import <AddressBookUI/AddressBookUI.h>

#import "Constants.h"


static CGFloat kCellFactoryAddressBookItemHeight = 0.0f;

static NSDictionary *kCellFactoryIcons = nil;

static BOOL kCellFactoryStaticInitialized = NO;
void cellFactoryStaticInitializer() {
  if (kCellFactoryStaticInitialized) {
    return;
  }

  kCellFactoryIcons = [[NSDictionary dictionaryWithObjectsAndKeys:
                           [UIImage imageNamed:@"buttonIcon_user.png"], @"user",
                           nil] retain];

  kCellFactoryStaticInitialized = YES;
}


@implementation CellFactory


#pragma mark Initialization


- (id)initWithStandardCellFactory:(CellFactory *)cellFactory {
  cellFactoryStaticInitializer();

  if (self = [super initWithNib:@"CellViews"]) {
    standardCellFactory = [cellFactory retain]; // Retaining, cleaning up in dealloc.
  }
  return self;
}


#pragma mark Cleanup


- (void)dealloc {
  [standardCellFactory release];
  standardCellFactory = nil;

  [super dealloc];
}


#pragma mark -


+ (UITableViewCell *)addressBookItemCellForTable:(UITableView *)tableView
                     personData:(NSDictionary *)personData {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];

  UITableViewCell *cell = [appDelegate.cellFactory cellOfType:@"addressBookItem"
                                                   forTable:tableView];
  UILabel *name = (UILabel *) [cell viewWithTag:kCellViewAddressBookItemNameTag];
  name.text = [PersonDataUtils displayName:personData];
    
  CcAvatarButtonIcon *avatarButtonIcon =
      (CcAvatarButtonIcon *) [cell viewWithTag:kCellViewAddressBookItemAvatarButtonIconTag];
  UIImage *image = [personData valueForKey:@"image"];
  [avatarButtonIcon setAvatar:image];

  return cell;
}


- (UITableViewCell *)cellOfType:(NSString*)cellType forTable:(UITableView*)aTableView {
  UITableViewCell *cell = [super cellOfType:cellType forTable:aTableView];
  if (!cell) {
    return [standardCellFactory cellOfType:cellType forTable:aTableView];
  }
    
  return cell;
}


+ (CGFloat)heightForAddressBookItemCellForTable:(UITableView *)tableView {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];

  if (!kCellFactoryAddressBookItemHeight) {
    UITableViewCell *cell =
        [appDelegate.cellFactory cellOfType:@"addressBookItem" forTable:tableView];
    kCellFactoryAddressBookItemHeight = cell.frame.size.height;
  }
  
  return kCellFactoryAddressBookItemHeight;
}


- (NSArray *)imagesToCache {
  return [NSArray arrayWithObjects:@"nonInteractiveItemBackground.png", nil];
}


- (void)setupDefaultsForCell:(UITableViewCell *)cell ofType:(NSString *)cellType {
  UIImageView *backgroundView = (UIImageView *) cell.backgroundView;
  //UIImageView *selectedBackgroundView = (UIImageView *) cell.selectedBackgroundView;

  if ([cellType isEqualToString:@"addressBookItem"]) {
    UIView *avatarButtonIconPlaceholder =
        (UIView *) [cell viewWithTag:kCellViewAddressBookItemAvatarButtonIconTag];

    backgroundView.image = [images valueForKey:@"nonInteractiveItemBackground.png"];

    CcAvatarButtonIcon *avatarButtonIcon = [[[CcAvatarButtonIcon alloc] init] autorelease];
    avatarButtonIcon.frame = avatarButtonIconPlaceholder.frame;
    avatarButtonIcon.tag = kCellViewAddressBookItemAvatarButtonIconTag;
    [[avatarButtonIconPlaceholder superview] replaceSubview:avatarButtonIconPlaceholder
                                             with:avatarButtonIcon];
  }
}


@end
