#import <UIKit/UIKit.h>


@interface UITableView (cliqcliq)

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
        atScrollPosition:(UITableViewScrollPosition)scrollPosition
        animated:(BOOL)animated
        keyboardAndToolbarVisible:(BOOL)keyboardAndToolbarVisible;

@end
