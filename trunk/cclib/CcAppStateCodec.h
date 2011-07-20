#import <Foundation/Foundation.h>


@protocol CcAppStateCodec

- (NSDictionary *)restoreStateAtLevel:(int)level values:(NSDictionary *)values;
- (void)saveStateAtLevel:(int)level;

@end
