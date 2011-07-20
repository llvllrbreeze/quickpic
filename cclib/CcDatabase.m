#import "CcDatabase.h"

#import "CcConfiguration.h"


@implementation CcDatabase


@synthesize database;


#pragma mark Initialization


+ (CcDatabase *)databaseWithFile:(const NSString *)path {
  sqlite3 *database;
  
  if (!sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
    sqlite3_close(database);
    NSAssert1(0, @"Unable to open database file: %s", sqlite3_errmsg(database));
    return nil;
  }

  CcDatabase *db = [[[CcDatabase alloc] init] autorelease];
  db.database = database;
  
  return db;
}


#pragma mark Cleanup


- (void)dealloc {
  sqlite3_close(database);
  self.database = NULL;

  [super dealloc];
}


#pragma mark -


+ (NSString *)escapeForSqlString:(const NSString *)string {
  return [string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}


- (int)executePreparedStatement:(sqlite3_stmt *)statement {
  if (sqlite3_step(statement) != SQLITE_DONE) {
    #ifdef DEBUG_SQL_ERRORS
      NSLog(@"%s\nSQL Error: %s", sqlite3_sql(statement), sqlite3_errmsg(self.database));
    #endif
  }
  sqlite3_finalize(statement);
  return sqlite3_last_insert_rowid(self.database);
}


- (int)executeStatement:(NSString *)query {
  sqlite3_stmt *statement = [self prepareStatement:query];
  if (sqlite3_step(statement) != SQLITE_DONE) {
    #ifdef DEBUG_SQL_ERRORS
      NSLog(@"%@\nSQL Error: %s", query, sqlite3_errmsg(self.database));
    #endif
  }
  sqlite3_finalize(statement);
  return sqlite3_last_insert_rowid(self.database);
}


- (sqlite3_stmt *)prepareStatement:(NSString *)statementString {
    #ifdef DEBUG_SQL_SELECT_STATEMENTS
      if ([[statementString lowercaseString] hasPrefix:@"select"]) {
        NSLog(@"%@", statementString);
      }
    #else
    #ifdef DEBUG_SQL_INSERT_STATEMENTS
      if ([[statementString lowercaseString] hasPrefix:@"insert"]) {
        NSLog(@"%@", statementString);
      }
    #else
    #ifdef DEBUG_SQL_UPDATE_STATEMENTS
      if ([[statementString lowercaseString] hasPrefix:@"update"]) {
        NSLog(@"%@", statementString);
      }
    #endif
    #endif
    #endif
    
    const char *sql = [statementString cStringUsingEncoding:NSUTF8StringEncoding];

    sqlite3_stmt *statement;
    int result = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);

    if (result == SQLITE_OK) {
      return statement;
    } else {
      #ifdef DEBUG_SQL_ERRORS
        NSLog(@"%@\nSQL Error: %s", statementString, sqlite3_errmsg(self.database));
      #endif

      sqlite3_finalize(statement);
      return NULL;
    }
}


+ (NSString *)stringForColumn:(int)columnIndex withStatement:(sqlite3_stmt *)statement {
  const char *value = (const char *) sqlite3_column_text(statement, columnIndex);
  return [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
}


@end
