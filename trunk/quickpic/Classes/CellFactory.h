#import <cclib/Cclib.h>


@interface CellFactory : CcCellFactory {
@private
  CcCellFactory *standardCellFactory;
}

+ (UITableViewCell *)addressBookItemCellForTable:(UITableView *)tableView
                     personData:(NSDictionary *)personData;
+ (CGFloat)heightForAddressBookItemCellForTable:(UITableView *)tableView;
- (id)initWithStandardCellFactory:(CcCellFactory *)cellFactory;

@end
