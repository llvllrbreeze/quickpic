#import "CcMediaDataSourceItemPicker.h"

#import "../CcAppDelegate.h"
#import "../CcUtils.h"
#import "../UIView+cliqcliq.h"
#import "CcMediaDataSource.h"
#import "CcMediaDataSourceItemPickerRow.h"


#define IMAGES_PER_ROW 4
#define ROW_HEIGHT 79

@interface CcMediaDataSourceItemPicker ()
  @property (nonatomic, readonly) int firstRowOnCurrentPage;
  @property (nonatomic, readonly) int maxRowsPerPage;
  @property (nonatomic, readonly) int pageCount;
  @property (nonatomic, readonly) int rowCount;

  - (BOOL)rowIsOnCurrentPage:(int)rowIndex;
  - (void)search:(NSString *)query;
  - (void)updateResultsFrame;
  - (void)updateView;
@end


@implementation CcMediaDataSourceItemPicker


@synthesize delegate;


#pragma mark Initialization


- (id)initWithDataSource:(NSObject <CcMediaDataSource> *)theDataSource {
  if (self = [super init]) {
    dataSource = [theDataSource retain]; // Retaining, cleaning up in dealloc.
    [dataSource addDelegate:self];

    rows = [[NSMutableArray array] retain]; // Retaining, cleaning up in dealloc.

    CcAppDelegate *appDelegate = [CcAppDelegate instance];
    
    // If this is a different class, clear the settings.
    NSString *dataSourceClassName = NSStringFromClass([theDataSource class]);
    NSString *lastDataSourceClassName = [appDelegate.settings
        stringValueForKey:@"ccmediadatasourceitempicker.data-source-class"
        defaultValue:@""];
    if (![dataSourceClassName isEqualToString:lastDataSourceClassName]) {
      [appDelegate.settings removeValueForKey:@"ccmediadatasourceitempicker.search-query"];
      [appDelegate.settings removeValueForKey:@"ccmediadatasourceitempicker.page-number"];
    }
    
    [appDelegate.settings setStringValue:dataSourceClassName
                          forKey:@"ccmediadatasourceitempicker.data-source-class"];

    if ([dataSource isReady]) {
      [self mediaDataAvailabilityChanged:dataSource];
    }
  }
  return self;
}


- (void)viewDidLoad {
  self.title = [dataSource getTitle];

  searchBar.hidden = ![dataSource isSearchable];
  [self updateView];

  CcAppDelegate *appDelegate = [CcAppDelegate instance];
  NSString *lastQuery = [appDelegate.settings
      stringValueForKey:@"ccmediadatasourceitempicker.search-query"
      defaultValue:nil];
  if (lastQuery) {
    searchBar.text = lastQuery;
    [self search:lastQuery];
  }

  // This will only be effective if the results are stored in cache, otherwise the data availability
  // notification will be delayed and this will be canceled out.
  pageNumber = [appDelegate.settings intValueForKey:@"ccmediadatasourceitempicker.page-number"
                                     defaultValue:0];
  [self performSelector:@selector(setInitialPageNumber:)
        withObject:[NSNumber numberWithInt:pageNumber]
        afterDelay:0.0f];
}


#pragma mark Cleanup


- (void)dealloc {
  [dataSource cancel];
  [dataSource removeDelegate:self];

  [dataSource release];
  dataSource = nil;

  [loadingView release];
  loadingView = nil;

  [rows release];
  rows = nil;

  [super dealloc];
}


#pragma mark CcMediaDataAvailabilityChangedDelegate Methods


- (void)mediaDataAvailabilityChanged:(id)target {
  if ([dataSource isReady]) {
    pagingToolbar.hidden = self.pageCount <= 1;
    [self updateResultsFrame];
  }

  pageNumber = 0;

  CcAppDelegate *appDelegate = [CcAppDelegate instance];
  [appDelegate.settings setIntValue:pageNumber forKey:@"ccmediadatasourceitempicker.page-number"];

  [self updateView];
}


- (void)initialProgressChanged:(id)target progress:(float)progress {
  loadingProgressBar.progress = progress;
}


- (void)thumbnailProgressChanged:(id)target mediaIndex:(int)index progress:(float)progress {
  int rowIndex = index / 4;
  if ([self rowIsOnCurrentPage:rowIndex]) {
    int startingIndex = rowIndex * 4;

    CcMediaDataSourceItemPickerRow *row =
        (CcMediaDataSourceItemPickerRow *) [rows objectAtIndex:rowIndex - self.firstRowOnCurrentPage];

    if (progress >= 1.0f) {
      [row setImage:[dataSource thumbnailAtIndex:index]
           atIndex:index - startingIndex];
    } else if (progress < 0.0f) {
      // If an error occurred.
      
      [row setErrorImageAtIndex:index - startingIndex];
    }
  }
}


#pragma mark CcMediaPickedDelegate


- (void)mediaPicked:(int)mediaIndex {
  [delegate mediaPicked:mediaIndex];
}


#pragma mark UISearchBarDelegate


- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar {
  theSearchBar.text = @"";
  [self search:@""];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
  [self search:theSearchBar.text];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
  [theSearchBar setShowsCancelButton:YES animated:YES];
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
  [theSearchBar setShowsCancelButton:NO animated:YES];
}


#pragma mark -


- (int)firstRowOnCurrentPage {
  return self.maxRowsPerPage * pageNumber;
}


- (int)maxRowsPerPage {
  float usableHeight = self.view.frame.size.height;
  if ([dataSource isSearchable]) {
    usableHeight -= searchBar.frame.size.height;
  }
  
  int maxRowsWithoutPagingControl = (int) (usableHeight / ROW_HEIGHT);
  int maxRowsWithPagingControl = 
      (int) ((usableHeight - pagingToolbar.frame.size.height) / ROW_HEIGHT);

  if (self.rowCount <= maxRowsWithoutPagingControl) {
    return maxRowsWithoutPagingControl;
  } else {
    return maxRowsWithPagingControl;
  }
}


- (IBAction)onNextPageButtonClicked {
  pageNumber++;
  [self updateView];

  CcAppDelegate *appDelegate = [CcAppDelegate instance];
  [appDelegate.settings setIntValue:pageNumber forKey:@"ccmediadatasourceitempicker.page-number"];
}


- (IBAction)onPreviousPageButtonClicked {
  pageNumber--;
  [self updateView];

  CcAppDelegate *appDelegate = [CcAppDelegate instance];
  [appDelegate.settings setIntValue:pageNumber forKey:@"ccmediadatasourceitempicker.page-number"];
}


- (int)pageCount {
  return (int) ceil([dataSource mediaCount] / (float) (self.maxRowsPerPage * IMAGES_PER_ROW));
}


- (void)refresh {
  [self updateView];
}


- (int)rowCount {
  return (int) ceil([dataSource mediaCount] / (float) IMAGES_PER_ROW);
}


- (BOOL)rowIsOnCurrentPage:(int)rowIndex {
  int firstRow = self.firstRowOnCurrentPage;
  return rowIndex >= firstRow && rowIndex < firstRow + self.maxRowsPerPage;
}


- (void)search:(NSString *)query {
  [searchBar resignFirstResponder];

  [dataSource setSearchQuery:query];

  loadingProgressBar.progress = 0;
  pagingToolbar.hidden = YES;
  [self updateResultsFrame];

  [self updateView];

  CcAppDelegate *appDelegate = [CcAppDelegate instance];
  [appDelegate.settings setStringValue:query forKey:@"ccmediadatasourceitempicker.search-query"];
}


- (void)setInitialPageNumber:(NSNumber *)thePageNumber {
  pageNumber = [thePageNumber intValue];
  [self updateView];
}


- (void)updateResultsFrame {
  int usableHeight = 328 + (searchBar.hidden ? 44 : 0) + (pagingToolbar.hidden ? 44 : 0);
  
  results.frame = CGRectMake(0, searchBar.hidden ? 0 : 44, 320, usableHeight);
}


- (void)updateView {
  [results removeAllSubviews];
  
  [rows removeAllObjects];
  
  if ([dataSource isReady] && [dataSource mediaCount]) {
    previousPageButton.enabled = pageNumber > 0;
    nextPageButton.enabled = pageNumber < self.pageCount - 1;

    int firstRow = self.firstRowOnCurrentPage;
    int lastRow = firstRow + self.maxRowsPerPage - 1;
    for (int rowIndex = firstRow; rowIndex <= lastRow; rowIndex++) {
      int startingIndex = rowIndex * IMAGES_PER_ROW;
      CcMediaDataSourceItemPickerRow *row = [[[CcMediaDataSourceItemPickerRow alloc]
          initWithStartingIndex:startingIndex] autorelease];
      row.delegate = self;
      row.view.frame = row.view.frame; // Forwing view to load.
      [rows addObject:row];

      int lastPhotoIndex = MIN(startingIndex + IMAGES_PER_ROW, [dataSource mediaCount]) - 1;
      for (int photoIndex = startingIndex; photoIndex <= lastPhotoIndex; photoIndex++) {
        int index = photoIndex - startingIndex;
        if ([dataSource requestThumbnailAtIndex:photoIndex]) {
          [row setImage:[dataSource thumbnailAtIndex:photoIndex] atIndex:index];
        } else {
          [row setLoadingImageAtIndex:index];
        }
      }

      row.view.frame = CGRectWithY(row.view.frame, (rowIndex - firstRow) * ROW_HEIGHT);
      [results addSubview:row.view];
    }
  } else {
    if ([dataSource hadError]) {
      loadingMessage.text = @"Unable to load images";
      loadingProgressBar.hidden = YES;
    } else if ([dataSource isReady] && ![dataSource mediaCount]) {
      loadingMessage.text = @"No photos found";
      loadingProgressBar.hidden = YES;
    } else {
      loadingMessage.text = @"Loading";
      loadingProgressBar.hidden = NO;
    }
    [results addSubview:loadingView];
  }
}


@end
