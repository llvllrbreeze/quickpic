#import <UIKit/UIKit.h>


@interface CcButtonItemListTableViewController : UITableViewController {
@private
  NSDictionary *handlers;
  NSDictionary *icons;
  NSArray *keys;
  NSDictionary *labels;
  NSArray *sectionNames;
}

@property (nonatomic, retain) NSDictionary *handlers;
@property (nonatomic, retain) NSDictionary *icons;
@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, retain) NSDictionary *labels;
@property (nonatomic, retain) NSArray *sectionNames;

@end
