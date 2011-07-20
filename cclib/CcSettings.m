#import "CcSettings.h"

#import "CcDatabase.h"


@interface CcSettings ()
  @property (nonatomic, retain) CcDatabase *database;
@end


@implementation CcSettings


@synthesize database;


#pragma mark Initialization


+ (CcSettings *)settingsWithDatabase:(CcDatabase *)database {
  CcSettings *settings = [[[CcSettings alloc] init] autorelease];
  settings.database = database;
  return settings;
}


#pragma mark Cleanup

- (void)dealloc {
  self.database = nil;

  [super dealloc];
}


#pragma mark -


- (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue {
  if (![self hasValueForKey:key]) {
    return defaultValue;
  }

  NSString *query = [NSString stringWithFormat:@"SELECT float_value FROM settings WHERE key = '%@'",
                                               [CcDatabase escapeForSqlString:key]];
  sqlite3_stmt *statement = [self.database prepareStatement:query];
  float value = 0.0f;
  if (sqlite3_step(statement) == SQLITE_ROW) {
    value = (float) sqlite3_column_double(statement, 0);
  }
  
  sqlite3_finalize(statement);
  
  return value;
}


- (BOOL)hasValueForKey:(NSString *)key {
  NSString *query = [NSString stringWithFormat:@"SELECT id FROM settings WHERE key = '%@'",
                                               [CcDatabase escapeForSqlString:key]];
  sqlite3_stmt *statement = [self.database prepareStatement:query];
  BOOL hasValue = NO;
  if (sqlite3_step(statement) == SQLITE_ROW) {
    hasValue = YES;
  }
  
  sqlite3_finalize(statement);
  
  return hasValue;
}


- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue {
  if (![self hasValueForKey:key]) {
    return defaultValue;
  }

  NSString *query = [NSString stringWithFormat:@"SELECT int_value FROM settings WHERE key = '%@'",
                                               [CcDatabase escapeForSqlString:key]];
  sqlite3_stmt *statement = [self.database prepareStatement:query];
  int value = 0;
  if (sqlite3_step(statement) == SQLITE_ROW) {
    value = sqlite3_column_int(statement, 0);
  }
  
  sqlite3_finalize(statement);
  
  return value;
}


- (NSArray *)keys {
  NSMutableArray *keys = [NSMutableArray array];

  NSString *query = @"SELECT key FROM settings ORDER BY key";
  sqlite3_stmt *statement = [self.database prepareStatement:query];
  while (sqlite3_step(statement) == SQLITE_ROW) {
    NSString *key = [CcDatabase stringForColumn:0 withStatement:statement];
    [keys addObject:key];
  }
  
  sqlite3_finalize(statement);
  
  return keys;
}


- (BOOL)removeValueForKey:(NSString *)key {
  if (![self hasValueForKey:key]) {
    return NO;
  }
  
  NSString *query = [NSString stringWithFormat:@"DELETE FROM settings WHERE key = '%@'",
                                               [CcDatabase escapeForSqlString:key]];
  [self.database executeStatement:query];
  
  return YES;
}


- (void)setFloatValue:(float)value forKey:(NSString *)key {
  if ([self hasValueForKey:key]) {
    // If the key already exists, change the value.
  
    NSString *query = [NSString
        stringWithFormat:@"UPDATE settings SET float_value=%f WHERE key = '%@'",
                         value,
                         [CcDatabase escapeForSqlString:key]];
    [self.database executeStatement:query];
  } else {
    // If the key does not already exist, insert the value.
    
    NSString *query = [NSString
        stringWithFormat:@"INSERT INTO settings (key, float_value) VALUES ('%@', %f)",
                         [CcDatabase escapeForSqlString:key],
                         value];
    [self.database executeStatement:query];
  }
}


- (void)setIntValue:(int)value forKey:(NSString *)key {
  if ([self hasValueForKey:key]) {
    // If the key already exists, change the value.
  
    NSString *query = [NSString
        stringWithFormat:@"UPDATE settings SET int_value=%d WHERE key = '%@'",
                         value,
                         [CcDatabase escapeForSqlString:key]];
    [self.database executeStatement:query];
  } else {
    // If the key does not already exist, insert the value.
    
    NSString *query = [NSString
        stringWithFormat:@"INSERT INTO settings (key, int_value) VALUES ('%@', %d)",
                         [CcDatabase escapeForSqlString:key],
                         value];
    [self.database executeStatement:query];
  }
}


- (void)setStringValue:(NSString *)value forKey:(NSString *)key {
  if ([self hasValueForKey:key]) {
    // If the key already exists, change the value.
  
    NSString *query = [NSString
        stringWithFormat:@"UPDATE settings SET string_value='%@' WHERE key = '%@'",
                         [CcDatabase escapeForSqlString:value],
                         [CcDatabase escapeForSqlString:key]];
    [self.database executeStatement:query];
  } else {
    // If the key does not already exist, insert the value.
    
    NSString *query = [NSString
        stringWithFormat:@"INSERT INTO settings (key, string_value) VALUES ('%@', '%@')",
                         [CcDatabase escapeForSqlString:key],
                         [CcDatabase escapeForSqlString:value]];
    [self.database executeStatement:query];
  }
}


- (NSString *)stringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
  if (![self hasValueForKey:key]) {
    return defaultValue;
  }

  NSString *query = [NSString
      stringWithFormat:@"SELECT string_value FROM settings WHERE key = '%@'",
                       [CcDatabase escapeForSqlString:key]];
  sqlite3_stmt *statement = [self.database prepareStatement:query];
  NSString *value = nil;
  if (sqlite3_step(statement) == SQLITE_ROW) {
    value = [CcDatabase stringForColumn:0 withStatement:statement];
  }
  
  sqlite3_finalize(statement);
  
  return value;
}


@end
