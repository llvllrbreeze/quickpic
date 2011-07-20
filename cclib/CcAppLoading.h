#import <UIKit/UIKit.h>


@interface CcAppLoading : UIViewController {
@protected
  IBOutlet UIProgressView *progressView;
  
@private
  int step;
}

- (const NSString *)databaseFilename;
- (UIViewController *)homeViewController;
- (BOOL)initializeDatabaseFromLegacyProduct:(NSString *)databasePath;
- (NSDictionary *)viewClassesDictionary;

@end
