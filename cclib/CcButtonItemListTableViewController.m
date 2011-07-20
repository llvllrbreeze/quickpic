#import "CcButtonItemListTableViewController.h"

#import "CcAppDelegate.h"
#import "CcCellFactory.h"
#import "CcConstants.h"


static CGFloat kCcButtonItemListTableViewControllerButtonItemSectionHeaderHeight = 0.0f;
static CGFloat kCcButtonItemListTableViewControllerButtonItemWithIconHeight = 0.0f;


@implementation CcButtonItemListTableViewController


@synthesize handlers;
@synthesize icons;
@synthesize keys;
@synthesize labels;
@synthesize sectionNames;


#pragma mark Cleanup


- (void)dealloc {
  self.handlers = nil;
  self.icons = nil;
  self.keys = nil;
  self.labels = nil;
  self.sectionNames = nil;

  [super dealloc];
}


#pragma mark UITableViewDataSource Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.keys count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];

  UITableViewCell *cell = [appDelegate.cellFactory cellOfType:@"buttonItemWithIcon"
                                                   forTable:tableView];
  UIImageView *icon = (UIImageView *) [cell viewWithTag:kStandardCellViewButtonItemWithIconIconTag];
  UILabel *label = (UILabel *) [cell viewWithTag:kStandardCellViewButtonItemWithIconLabelTag];

  NSArray *sectionKeys = [self.keys objectAtIndex:indexPath.section];
  NSString *key = [sectionKeys objectAtIndex:indexPath.row];

  icon.image = [self.icons valueForKey:key];
  label.text = [self.labels valueForKey:key];
  
  return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[self.keys objectAtIndex:section] count];
}


#pragma mark UITableViewDelegate Methods


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  int row = indexPath.row;

  NSArray *sectionKeys = [self.keys objectAtIndex:indexPath.section];

  NSString *key = row < [sectionKeys count] ? [sectionKeys objectAtIndex:row] : nil;
  if (!key) {
    return;
  }

  NSString *selectorString = [self.handlers valueForKey:key];
  
  if (selectorString) {
    [self performSelector:NSSelectorFromString(selectorString)];
  }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];
  
  if (!kCcButtonItemListTableViewControllerButtonItemSectionHeaderHeight) {
    UITableViewCell *cell = [appDelegate.cellFactory cellOfType:@"buttonItemSectionHeader"
                                                     forTable:tableView];
    kCcButtonItemListTableViewControllerButtonItemSectionHeaderHeight = cell.frame.size.height;
  }
  
  return kCcButtonItemListTableViewControllerButtonItemSectionHeaderHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];

  if (!kCcButtonItemListTableViewControllerButtonItemWithIconHeight) {
    UITableViewCell *cell = [appDelegate.cellFactory cellOfType:@"buttonItemWithIcon"
                                                     forTable:tableView];
    kCcButtonItemListTableViewControllerButtonItemWithIconHeight = cell.frame.size.height;
  }
  
  return kCcButtonItemListTableViewControllerButtonItemWithIconHeight;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  NSString *sectionName = [self.sectionNames objectAtIndex:section];
  if ([sectionName isEqualToString:@""]) {
    return nil;
  }

  CcAppDelegate *appDelegate = [CcAppDelegate instance];

  UITableViewCell *cell = [appDelegate.cellFactory cellOfType:@"buttonItemSectionHeader"
                                                   forTable:tableView];
  UILabel *label = (UILabel *)[cell viewWithTag:kStandardCellViewButtonItemSectionHeaderLabelTag];

  label.text = sectionName;

  return cell;
}


@end
