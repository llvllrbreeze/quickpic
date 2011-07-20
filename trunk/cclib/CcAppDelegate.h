#import <UIKit/UIKit.h>

#import "CcDatabase.h"
#import "CcSettings.h"


@class CcCellFactory;


@interface CcAppDelegate : NSObject <UIApplicationDelegate> {
@protected
  IBOutlet UINavigationController *navigationController;
  IBOutlet UIWindow *window;
  
@private
  CcCellFactory *cellFactory;
  CcDatabase *database;
  CcSettings *settings;
}

@property (nonatomic, retain) CcCellFactory *cellFactory;
@property (nonatomic, retain) CcDatabase *database;
@property (nonatomic, assign) UINavigationController *navigationController;
@property (nonatomic, retain) CcSettings *settings;
@property (nonatomic, assign) UIWindow *window;

+ (void)init:(CcAppDelegate *)theAppDelegate;
- (void)initializeApplication;
- (void)initializeCellFactory;
- (void)initializationComplete;
+ (CcAppDelegate *)instance;
- (void)showAbout;

@end
