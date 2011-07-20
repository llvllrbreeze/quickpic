#import <Foundation/Foundation.h>


@class CcDatabase;


@interface CcSettings : NSObject {
  @private
    CcDatabase *database;
}


- (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue;
- (BOOL)hasValueForKey:(NSString *)key;
- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue;
- (NSArray *)keys;
- (BOOL)removeValueForKey:(NSString *)key;
- (void)setFloatValue:(float)value forKey:(NSString *)key;
- (void)setIntValue:(int)value forKey:(NSString *)key;
- (void)setStringValue:(NSString *)value forKey:(NSString *)key;
+ (CcSettings *)settingsWithDatabase:(CcDatabase *)database;
- (NSString *)stringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;


@end
