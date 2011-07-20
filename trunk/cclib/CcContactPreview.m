#import "CcContactPreview.h"

#import "CcAppDelegate.h"
#import "CcCellFactory.h"
#import "CcConstants.h"
#import "CcUtils.h"
#import "NSDictionary+cliqcliq.h"
#import "PersonDataUtils.h"


static const int kContactPreviewAddressSection = 3;
static const int kContactPreviewEmailSection = 2;
static const int kContactPreviewFooterSection = 4;
static const int kContactPreviewHeaderSection = 0;
static const int kContactPreviewPhoneSection = 1;

static const CGFloat kContactPreviewDefaultItemHeight = 22.0f;
static const CGFloat kContactPreviewDefaultSectionHeaderHeight = 10.0f;


@interface CcContactPreview ()
  - (void)adjustLabelHeight:(UILabel *)label;
  - (void)recenterNameAndCompanyLabels;
  - (UITableViewCell *)sectionHeaderForTableView:(UITableView *)tableView;
@end


@implementation CcContactPreview


@synthesize personData;


#pragma mark Initialization


- (id)initWithPersonData:(NSDictionary *)thePersonData {
  if (self = [super initWithNibName:@"CcContactPreview" bundle:[NSBundle mainBundle]]) {
    personData = [thePersonData retain]; // Retaining, cleaning up in dealloc.
  }
  return self;
}


- (void)viewDidLoad {
  photo.image = [personData valueForKey:@"image"
                            defaultValue:[UIImage imageNamed:@"defaultAvatar.png"]];
  nameLabel.text = [PersonDataUtils displayName:personData];
  companyLabel.text = [PersonDataUtils displayCompanyInfo:personData];
  
  [self adjustLabelHeight:companyLabel];

  [self recenterNameAndCompanyLabels];
}


#pragma mark Cleanup


- (void)dealloc {
  [personData release];
  personData = nil;

  [super dealloc];
}


#pragma mark UITableViewDataSource Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  int section = indexPath.section;
  int row = indexPath.row;

  if (section == kContactPreviewHeaderSection) {
    return headerCell;
  } else if (section > kContactPreviewHeaderSection && section < kContactPreviewFooterSection) {
    UITableViewCell *cell = [[CcAppDelegate instance].cellFactory
        cellOfType:section == kContactPreviewAddressSection ? @"addressContactItem" : @"contactItem"
        forTable:tableView];
    UILabel *typeLabel = (UILabel *) [cell viewWithTag:kStandardCellViewContactItemTypeTag];
    UILabel *valueLabel = (UILabel *) [cell viewWithTag:kStandardCellViewContactItemValueTag];

    if (section == kContactPreviewPhoneSection) {
      NSArray *phoneNumbers = [personData valueForKey:@"phone_numbers"];
      NSArray *phoneNumberData = [phoneNumbers objectAtIndex:row];
      typeLabel.text = [phoneNumberData objectAtIndex:1];
      valueLabel.text = [phoneNumberData objectAtIndex:0];
    } else if (section == kContactPreviewEmailSection) {
      NSArray *emailAddresses = [personData valueForKey:@"email_addresses"];
      NSArray *emailAddressData = [emailAddresses objectAtIndex:row];
      typeLabel.text = [emailAddressData objectAtIndex:1];
      valueLabel.text = [emailAddressData objectAtIndex:0];
    } else if (section == kContactPreviewAddressSection) {
      NSArray *addresses = [personData valueForKey:@"addresses"];
      NSArray *addressData = [addresses objectAtIndex:row];
      NSString *address = [PersonDataUtils displayAddress:[addressData objectAtIndex:0]];

      typeLabel.text = [addressData objectAtIndex:1];
      valueLabel.text = address;
      [self adjustLabelHeight:valueLabel];
    }
    
    return cell;
  } else /*if (section == kContactPreviewFooterSection)*/ {
    return footerCell;
  }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == kContactPreviewHeaderSection) {
    return 1;
  } else if (section == kContactPreviewPhoneSection) {
    NSArray *phoneNumbers = [personData valueForKey:@"phone_numbers"];
    return [phoneNumbers count];
  } else if (section == kContactPreviewEmailSection) {
    NSArray *emailAddresses = [personData valueForKey:@"email_addresses"];
    return [emailAddresses count];
  } else if (section == kContactPreviewAddressSection) {
    NSArray *addresses = [personData valueForKey:@"addresses"];
    return [addresses count];
  } else /*if (section == kContactPreviewFooterSection)*/ {
    return 1;
  }
}


#pragma mark UITableViewDelegate Methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  int section = indexPath.section;
  int row = indexPath.row;
  
  if (section == kContactPreviewHeaderSection) {
    return headerCell.frame.size.height;
  } else if (section == kContactPreviewPhoneSection) {
    return kContactPreviewDefaultItemHeight;
  } else if (section == kContactPreviewEmailSection) {
    return kContactPreviewDefaultItemHeight;
  } else if (section == kContactPreviewAddressSection) {
    NSArray *addresses = [personData valueForKey:@"addresses"];
    NSArray *addressData = [addresses objectAtIndex:row];
    NSString *address = [PersonDataUtils displayAddress:[addressData objectAtIndex:0]];
    return [address sizeWithFont:[UIFont systemFontOfSize:15.0f] // todo
                    constrainedToSize:CGSizeMake(208.0f, 999.0f)
                    lineBreakMode:UILineBreakModeWordWrap].height + 4.0f;
  } else /*if (section == kContactPreviewFooterSection)*/ {
    return footerCell.frame.size.height;
  }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == kContactPreviewHeaderSection) {
    return nil;
  } else if (section == kContactPreviewPhoneSection) {
    NSArray *phoneNumbers = [personData valueForKey:@"phone_numbers"];
    return [phoneNumbers count] > 0 ? [self sectionHeaderForTableView:tableView] : nil;
  } else if (section == kContactPreviewEmailSection) {
    NSArray *emailAddresses = [personData valueForKey:@"email_addresses"];
    return [emailAddresses count] > 0 ? [self sectionHeaderForTableView:tableView] : nil;
  } else if (section == kContactPreviewAddressSection) {
    NSArray *addresses = [personData valueForKey:@"addresses"];
    return [addresses count] > 0 ? [self sectionHeaderForTableView:tableView] : nil;
  } else /*if (section == kContactPreviewFooterSection)*/ {
    return nil;
  }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return kContactPreviewDefaultSectionHeaderHeight;
}


#pragma mark Private


- (void)adjustLabelHeight:(UILabel *)label {
  label.numberOfLines = 3;
  label.lineBreakMode = UILineBreakModeWordWrap;
  
  CGSize newCompanyLabelSize = [label.text
      sizeWithFont:label.font
      constrainedToSize:CGSizeMake(label.frame.size.width, 999.0f)
      lineBreakMode:label.lineBreakMode];
  label.frame = CGRectWithHeight(label.frame, newCompanyLabelSize.height);
}


- (void)recenterNameAndCompanyLabels {
  CGFloat nameLabelHeight = nameLabel.frame.size.height;
  CGFloat usedHeight = nameLabelHeight + companyLabel.frame.size.height - 2.0f;
  CGFloat offset = (photo.frame.size.height - usedHeight) / 2.0f + photo.frame.origin.y;
  nameLabel.frame = CGRectWithY(nameLabel.frame, (int) offset);
  companyLabel.frame = CGRectWithY(companyLabel.frame, (int) (offset + nameLabelHeight - 2.0f));
}


- (UITableViewCell *)sectionHeaderForTableView:(UITableView *)tableView {
  return [[CcAppDelegate instance].cellFactory cellOfType:@"contactSectionHeader"
                                               forTable:tableView];
}


@end
