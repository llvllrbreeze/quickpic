// Based on http://pegolon.wordpress.com/2008/11/15/using-uitableviewcell-with-interfacebuilder/

#import <UIKit/UIKit.h>


@interface CcCellFactory : NSObject {
@protected
  NSDictionary *images;
  NSMutableDictionary *viewTemplates;
}

+ (UITableViewCell *)buttonItemWithIconCellForTable:(UITableView *)tableView
                     icon:(UIImage *)icon
                     label:(NSString *)label;
- (UITableViewCell *)cellOfType:(NSString*)cellType forTable:(UITableView *)aTableView;
+ (UITableViewCell *)headerWithTitle:(NSString *)title forTable:(UITableView *)tableView;
+ (CGFloat)heightForButtonItemSectionHeaderForTable:(UITableView *)tableView;
+ (CGFloat)heightForButtonItemWithIconCellForTable:(UITableView *)tableView;
- (NSArray *)imagesToCache;
- (id)initWithNib:(NSString *)aNibName;
- (void)setupDefaultsForCell:(UITableViewCell *)cell ofType:(NSString *)cellType;

@end
