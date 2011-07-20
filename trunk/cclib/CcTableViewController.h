#import <UIKit/UIKit.h>


@interface CcTableViewController : UITableViewController {
  @protected
    NSMutableSet *releaseOnDealloc;
}

@property (nonatomic, readonly, retain) NSMutableSet *releaseOnDealloc;

@end
