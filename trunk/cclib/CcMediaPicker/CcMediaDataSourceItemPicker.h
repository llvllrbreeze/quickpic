#import <UIKit/UIKit.h>

#import "CcMediaDataAvailabilityChangedDelegate.h"
#import "CcMediaPickedDelegate.h";


@protocol CcMediaDataSource;

@interface CcMediaDataSourceItemPicker : UIViewController <CcMediaDataAvailabilityChangedDelegate,
                                                           CcMediaPickedDelegate,
                                                           UISearchBarDelegate> {
  @private
    NSObject <CcMediaDataSource> *dataSource;
    NSObject <CcMediaPickedDelegate> *delegate;
    IBOutlet UIView *loadingView;
    IBOutlet UILabel *loadingMessage;
    IBOutlet UIProgressView *loadingProgressBar;
    IBOutlet UIBarButtonItem *nextPageButton;
    int pageNumber;
    IBOutlet UIToolbar *pagingToolbar;
    IBOutlet UIBarButtonItem *previousPageButton;
    IBOutlet UIView *results;
    NSMutableArray *rows;
    IBOutlet UISearchBar *searchBar;
}

@property (nonatomic, assign) NSObject <CcMediaPickedDelegate> *delegate;

- (id)initWithDataSource:(NSObject <CcMediaDataSource> *)theDataSource;
- (IBAction)onNextPageButtonClicked;
- (IBAction)onPreviousPageButtonClicked;
- (void)refresh;

@end
