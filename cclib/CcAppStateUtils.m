#import "CcAppStateUtils.h"

#import "CcAppDelegate.h"
#import "CcAppStateCodec.h"
#import "CcSettings.h"


@implementation CcAppStateUtils


+ (void)assertCorrectViewType:(NSString *)viewType level:(int)level {
  NSString *key = [CcAppStateUtils stateKey:@"view-type" level:level];
  NSString *value = [[CcAppDelegate instance].settings stringValueForKey:key defaultValue:nil];
  if (!value) {
    NSAssert1(0, @"State restoration failure: view-type: \"%@\" expected, none found.", viewType);
  } else if (![value isEqualToString:viewType]) {
    NSAssert2(0, @"State restoration failure: view-type: \"%@\" expected, \"%@\" found.", viewType,
                  value);
  }
}


+ (void)removeAllStateRecords {
  CcSettings *settings = [CcAppDelegate instance].settings;

  NSArray *keys = [settings keys];
  for (NSString *key in keys) {
    if ([key hasPrefix:@"state."]) {
      [settings removeValueForKey:key];
    }
  }
}


+ (void)saveApplicationState {
  CcAppDelegate *appDelegate = [CcAppDelegate instance];

  [CcAppStateUtils removeAllStateRecords];

  int level = 0;
  NSArray *viewControllers = appDelegate.navigationController.viewControllers;
  for (UIViewController <CcAppStateCodec> *viewController in viewControllers) {
    if ([viewController conformsToProtocol:@protocol(CcAppStateCodec)]) {
      [viewController saveStateAtLevel:level];

      level++;
    }
  }

  [appDelegate.settings setIntValue:level forKey:@"state.num-levels"];
}


+ (NSString *)stateKey:(NSString *)key level:(int)level {
  return [NSString stringWithFormat:@"state.%@[%d]", key, level];
}


@end
