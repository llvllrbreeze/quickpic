#import <Foundation/Foundation.h>


@interface CcAppStateUtils : NSObject {

}

+ (void)assertCorrectViewType:(NSString *)viewType level:(int)level;
+ (void)removeAllStateRecords;
+ (void)saveApplicationState;
+ (NSString *)stateKey:(NSString *)key level:(int)level;

@end
