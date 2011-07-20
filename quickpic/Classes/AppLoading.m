#import "AppLoading.h"

#import "AppDelegate.h"
#import "Home.h"


@implementation AppLoading


- (const NSString *)databaseFilename {
  return kAppDelegateDatabaseFilename;
}


- (UIViewController *)homeViewController {
  return [[[Home alloc] init] autorelease];
}


- (BOOL)initializeDatabaseFromLegacyProduct {
  return NO;
}


- (NSDictionary *)viewClassesDictionary {
  return [NSDictionary dictionaryWithObject:[Home class] forKey:@"Home"];
}


@end
