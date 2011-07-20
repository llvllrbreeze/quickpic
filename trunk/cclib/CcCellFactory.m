#import "CcCellFactory.h"

#import "CcAppDelegate.h"
#import "CcConstants.h"


static CGFloat kCcCellFactoryButtonItemSectionHeaderHeight = 0.0f;
static CGFloat kCcCellFactoryButtonItemWithIconHeight = 0.0f;


@implementation CcCellFactory


#pragma mark Initialization


- (id)initWithNib:(NSString *)aNibName {
  if (self == [super init]) {
    NSArray *imagesToCache = [self imagesToCache];

    images = [[NSMutableDictionary dictionaryWithCapacity:[imagesToCache count]] retain]; // Retaining, cleaning up in dealloc.
    for (NSString *imagePath in imagesToCache) {
      [(NSMutableDictionary *) images setValue:[UIImage imageNamed:imagePath] forKey:imagePath];
    }

    viewTemplates = [[NSMutableDictionary alloc] init]; // Not releasing, cleaning up in dealloc.
    NSArray *templates = [[NSBundle mainBundle] loadNibNamed:aNibName owner:self options:nil];
    for (id template in templates) {
      if ([template isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cellTemplate = (UITableViewCell *)template;
        NSString *key = cellTemplate.reuseIdentifier;
        if (key) {
          [viewTemplates setObject:[NSKeyedArchiver archivedDataWithRootObject:template]
                         forKey:key];
        } else {
          @throw [NSException exceptionWithName:@"Unknown cell"
                              reason:@"Cell has no reuseIdentifier"
                              userInfo:nil];
        }
      }
    }
  }

  return self;
}


#pragma mark Cleanup


- (void)dealloc {
  [images release];
  images = nil;

  [viewTemplates release];
  viewTemplates = nil;
  
  [super dealloc];
}


#pragma mark -


+ (UITableViewCell *)buttonItemWithIconCellForTable:(UITableView *)tableView
                     icon:(UIImage *)icon
                     label:(NSString *)label {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];
  
  UITableViewCell *cell = [appDelegate.cellFactory cellOfType:@"buttonItemWithIcon"
                                                   forTable:tableView];

  UIImageView *iconView =
      (UIImageView *) [cell viewWithTag:kStandardCellViewButtonItemWithIconIconTag];
  UILabel *labelView = (UILabel *) [cell viewWithTag:kStandardCellViewButtonItemWithIconLabelTag];

  iconView.image = icon;
  labelView.text = label;

  return cell;
}


- (UITableViewCell *)cellOfType:(NSString*)cellType forTable:(UITableView*)aTableView {
  UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellType];
  if (cell) {
    return cell;
  }

  NSData * cellData = [viewTemplates objectForKey:cellType];
  if (cellData) {
    cell = [NSKeyedUnarchiver unarchiveObjectWithData:cellData];

    [self setupDefaultsForCell:cell ofType:cellType];
    [cell prepareForReuse];

    return cell;
  }
    
  return nil;
}


+ (UITableViewCell *)headerWithTitle:(NSString *)title forTable:(UITableView *)tableView {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];

  UITableViewCell *cell = [appDelegate.cellFactory cellOfType:@"buttonItemSectionHeader"
                                                   forTable:tableView];
  UILabel *label = (UILabel *)[cell viewWithTag:kStandardCellViewButtonItemSectionHeaderLabelTag];

  label.text = title;

  return cell;
}


+ (CGFloat)heightForButtonItemSectionHeaderForTable:(UITableView *)tableView {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];
  
  if (!kCcCellFactoryButtonItemSectionHeaderHeight) {
    UITableViewCell *cell = [appDelegate.cellFactory cellOfType:@"buttonItemSectionHeader"
                                                     forTable:tableView];
    kCcCellFactoryButtonItemSectionHeaderHeight = cell.frame.size.height;
  }
  
  return kCcCellFactoryButtonItemSectionHeaderHeight;
}


+ (CGFloat)heightForButtonItemWithIconCellForTable:(UITableView *)tableView {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];  

  if (!kCcCellFactoryButtonItemWithIconHeight) {
    UITableViewCell *cell = [appDelegate.cellFactory cellOfType:@"buttonItemWithIcon"
                                                     forTable:tableView];
    kCcCellFactoryButtonItemWithIconHeight = cell.frame.size.height;
  }
  
  return kCcCellFactoryButtonItemWithIconHeight;
}


- (NSArray *)imagesToCache {
  return [NSArray arrayWithObjects:@"buttonItemDown.png",
                                   @"buttonItemsSectionHeaderBackground.png",
                                   @"buttonItemUp.png",
                                   @"contactBackground.png",
                                   nil];
}


- (void)setupDefaultsForCell:(UITableViewCell *)cell ofType:(NSString *)cellType {
  UIImageView *backgroundView = (UIImageView *) cell.backgroundView;
  UIImageView *selectedBackgroundView = (UIImageView *) cell.selectedBackgroundView;

  if ([cellType isEqualToString:@"buttonItemSectionHeader"]) {
    backgroundView.image = [images valueForKey:@"buttonItemsSectionHeaderBackground.png"];
  } else if ([cellType isEqualToString:@"buttonItemWithIcon"]) {
    backgroundView.image = [images valueForKey:@"buttonItemUp.png"];
    selectedBackgroundView.image = [images valueForKey:@"buttonItemDown.png"];
  } else if ([cellType isEqualToString:@"addressContactItem"] ||
             [cellType isEqualToString:@"contactItem"] ||
             [cellType isEqualToString:@"contactSectionHeader"]) {
    backgroundView.image = [images valueForKey:@"contactBackground.png"];
  }
}


@end
