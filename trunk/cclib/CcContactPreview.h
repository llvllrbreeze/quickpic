#import <UIKit/UIKit.h>


@interface CcContactPreview : UITableViewController {
@private
  IBOutlet UILabel *companyLabel;
  IBOutlet UITableViewCell *footerCell;
  IBOutlet UITableViewCell *headerCell;
  IBOutlet UILabel *nameLabel;
  NSDictionary *personData;
  IBOutlet UIImageView *photo;
}

@property (nonatomic, readonly) NSDictionary *personData;

- (id)initWithPersonData:(NSDictionary *)thePersonData;

@end
