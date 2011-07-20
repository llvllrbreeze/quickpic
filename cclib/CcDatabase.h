#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface CcDatabase : NSObject {
  @private
    sqlite3 *database;
}

@property (assign) sqlite3 *database;

+ (CcDatabase *)databaseWithFile:(const NSString *)path;
+ (NSString *)escapeForSqlString:(const NSString *)string;
- (int)executePreparedStatement:(sqlite3_stmt *)statement;
- (int)executeStatement:(NSString *)query;
- (sqlite3_stmt *)prepareStatement:(NSString *)statementString;
+ (NSString *)stringForColumn:(int)columnIndex withStatement:(sqlite3_stmt *)statement;

@end
