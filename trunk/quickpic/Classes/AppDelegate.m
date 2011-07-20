#import "AppDelegate.h"

#import "AppLoading.h"
#import "CellFactory.h"
#import "Constants.h"
#import "Home.h"


const NSString *kAppDelegateDatabaseFilename = @"appdb_1_0.sql";


@implementation AppDelegate


@synthesize allowEditing;
@synthesize allowFlickr;
@synthesize allowImages;
@synthesize allowMultipleContacts;
@synthesize allowMultipleMedia;
@synthesize allowVideo;
@synthesize continueToUrl;
@synthesize creativeCommonsOnly;
@synthesize defaultSource;
@synthesize getContactField;
@synthesize getContactInfo;
@synthesize maxImageSize;
@synthesize minContacts;
@synthesize minMedia;
@synthesize passContextToContinueUrl;
@synthesize postContext;
@synthesize postToUrl;
@synthesize resetHomeWhenBecomingActive;


#pragma mark Initialization


- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSURL *url = [launchOptions valueForKey:@"UIApplicationLaunchOptionsURLKey"];
  BOOL output = [self openedWithUrl:url];

  if (output) {
    [super applicationDidFinishLaunching:application];
  }

  return output;
}


- (BOOL)application:(UIApplication *)application
        openURL:(NSURL *)url
        sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
  BOOL output = [self openedWithUrl:url];

  if (output) {
    [self reset];
  }

  return output;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  if (self.resetHomeWhenBecomingActive) {
    self.resetHomeWhenBecomingActive = NO;
    [self reset];
  }
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // Do nothing
}


- (void)initializationComplete {
  [super initializationComplete];

  BOOL allowStats = [self.settings intValueForKey:@"pref.allow-stats" defaultValue:1];
  if (allowStats) {
    [[GANTracker sharedTracker] startTrackerWithAccountID:GA_ACCOUNT_ID
                                dispatchPeriod:10
                                delegate:nil];
  }
}


- (void)initializeApplication {
  self.window.rootViewController = [[[AppLoading alloc] init] autorelease];
}


- (void)initializeCellFactory {
  [super initializeCellFactory];
  self.cellFactory =
    [[[CellFactory alloc] initWithStandardCellFactory:self.cellFactory] autorelease];
}


- (BOOL)openedWithUrl:(NSURL *)url {
  self.allowEditing = NO;
  self.allowFlickr = YES;
  self.allowImages = YES;
  self.allowMultipleContacts = NO;
  self.allowMultipleMedia = NO;
  self.allowVideo = NO;
  self.continueToUrl = nil;
  self.creativeCommonsOnly = NO;
  self.defaultSource = -1;
  self.getContactField = nil;
  self.getContactInfo = NO;
  self.maxImageSize = CGSizeZero;
  self.minContacts = 0;
  self.minMedia = 1;
  self.passContextToContinueUrl = NO;
  self.postContext = @"";
  self.postToUrl = nil;

  if (!url) {
    self.allowMultipleMedia = YES;
    self.allowVideo = YES;
  }

  NSString *query = [url query];
  if ([query length] > 0) {
    NSArray *queryParts = [query componentsSeparatedByString:@"&"];
    for (NSString *queryPart in queryParts) {
      NSString *key;
      NSString *value;
      
      int indexOfEqualSign = [queryPart rangeOfString:@"="].location;
      if (indexOfEqualSign == NSNotFound) {
        key = queryPart;
        value = @"";
      } else {
        key = [queryPart substringToIndex:indexOfEqualSign];
        value = [queryPart substringFromIndex:indexOfEqualSign + 1];
      }
      
      NSString *unescapedValue =
          [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

      if ([key isEqualToString:@"action"]) {
        self.postToUrl = unescapedValue;
      } else if ([key isEqualToString:@"contact"]) {
        if ([value isEqualToString:@"0,1"]) {
          self.minContacts = 0;
          self.getContactInfo = YES;
        } else {
          sscanf([value cStringUsingEncoding:NSUTF8StringEncoding], "%d", &minContacts);

          BOOL hasPlusSuffix = [value rangeOfString:@"+"].location != NSNotFound;
          self.allowMultipleContacts = hasPlusSuffix;
          self.getContactInfo = [value hasPrefix:@"1"] || hasPlusSuffix;
        }

        if (self.getContactInfo && !self.allowMultipleContacts &&
                [value rangeOfString:@":"].location != NSNotFound) {
          self.getContactField = [[value componentsSeparatedByString:@":"] objectAtIndex:1];
        }
      } else if ([key isEqualToString:@"continue"]) {
        self.continueToUrl = unescapedValue;
      } else if ([key isEqualToString:@"context"]) {
        self.postContext = unescapedValue;
      } else if ([key isEqualToString:@"cconly"]) {
        self.creativeCommonsOnly = [value isEqualToString:@"1"];
      } else if ([key isEqualToString:@"edit"]) {
        self.allowEditing = [value isEqualToString:@"1"];
      } else if ([key isEqualToString:@"flickr"]) {
        self.allowFlickr = [value isEqualToString:@"1"];
      } else if ([key isEqualToString:@"images"]) {
        if ([value isEqualToString:@"0,1"]) {
          self.minMedia = 0;
          self.allowImages = YES;
        } else {
          int checkMinMedia;
          sscanf([value cStringUsingEncoding:NSUTF8StringEncoding], "%d", &checkMinMedia);
          self.minMedia = MAX(self.minMedia, checkMinMedia);

          BOOL hasPlusSuffix = [value rangeOfString:@"+"].location != NSNotFound;
          self.allowMultipleMedia = self.allowMultipleContacts || hasPlusSuffix;
          self.allowImages = [value hasPrefix:@"1"] || hasPlusSuffix;
        }
      } else if ([key isEqualToString:@"maxsize"]) {
        NSArray *components = [value componentsSeparatedByString:@","];
        if ([components count] == 1) {
            self.maxImageSize = CGSizeMake([value intValue], [value intValue]);
        } else if ([components count] == 2) {
            self.maxImageSize = CGSizeMake([[components objectAtIndex:0] intValue],
                                           [[components objectAtIndex:1] intValue]);
        }
      } else if ([key isEqualToString:@"passcontext"]) {
        self.passContextToContinueUrl = [value isEqualToString:@"1"];
      } else if ([key isEqualToString:@"source"]) { // ignored if contact is set
        if ([value isEqualToString:@"camera"]) {
          self.defaultSource = DefaultMediaPickerSourceCamera;
        } else if ([value isEqualToString:@"library"]) {
          self.defaultSource = DefaultMediaPickerSourcePhotoLibrary;
        } else if ([value isEqualToString:@"flickr"]) {
          self.defaultSource = DefaultMediaPickerSourceFlickr;
        }
      } else if ([key isEqualToString:@"v"]) {
        NSBundle *bundle = [NSBundle mainBundle];
        float version = [[bundle objectForInfoDictionaryKey:@"CFBundleVersion"] floatValue];
        float requiredVersion = [value floatValue];

        if (version < requiredVersion) {
          [CcUtils alert:[NSString stringWithFormat:
              @"This application requires Quickpic version %@ or greater.  Please update your Quickpic installation and try again.",
              value]];
          NSURL *itunesUrl = [@"http://itunes.apple.com/us/app/cliqcliq-quickpic/id347874926" url];
          [[UIApplication sharedApplication] performSelector:@selector(openURL:)
                                             withObject:itunesUrl
                                             afterDelay:2.0f];
          return NO;
        }
      } else if ([key isEqualToString:@"video"]) {
        if ([value isEqualToString:@"0,1"]) {
          self.minMedia = 0;
          self.allowVideo = YES;
        } else {
          int checkMinMedia;
          sscanf([value cStringUsingEncoding:NSUTF8StringEncoding], "%d", &checkMinMedia);
          self.minMedia = MAX(self.minMedia, checkMinMedia);

          BOOL hasPlusSuffix = [value rangeOfString:@"+"].location != NSNotFound;
          self.allowMultipleMedia = self.allowMultipleContacts || hasPlusSuffix;
          self.allowVideo = [value hasPrefix:@"1"] || hasPlusSuffix;
        }
      }
    }
  }

  // Forcing the source to be ignored if contact is set.  This is because it's easier, from a
  // usability point-of-view, to show the user the main menu after initially selecting a contact
  // rather than jumping to a photo picker.
  if (getContactInfo) {
    self.defaultSource = -1;
  }

  if (self.postToUrl) {
    NSURL *url = [self.postToUrl url];

    NSError *error;
    [[GANTracker sharedTracker] trackEvent:@"quickpic"
                                action:@"launched-for-service"
                                label:[url host]
                                value:-1
                                withError:&error];
  }
  
  return YES;
}


- (void)reset {
  // Resetting the home view in case it's called more than once.
  for (UIViewController *viewController in self.navigationController.viewControllers) {
    if ([viewController isKindOfClass:[Home class]]) {
      [(Home *) viewController reset];
      [self.navigationController popToViewController:viewController animated:NO];
    }
  }
}


@end
