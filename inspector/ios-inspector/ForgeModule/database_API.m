//
//  database_API.m
//  ForgeModule
//
//  Created by Alex Horak on 12/17/12.
//

#import "database_API.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@implementation database_API

// Takes an array of sqlite queries to construct the database schema.
+ (void)createTables:(ForgeTask *)task schema:(NSArray *)schema {
    
    // Locate Documents directory and open database.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    
    if (![database open]) {
        [task error: @"ERROR: createTables() was unable to open or create a database."];
    }
    [database open];
    
    // Iterate through the array and create a table with each name and then run the query
    for (NSDictionary * dataDict in schema) {
        NSString * NAME = [dataDict objectForKey:@"name"];
        NSString * SCHEMA = [dataDict objectForKey:@"schema"];
        NSString * QUERY = [NSString stringWithFormat:@"CREATE TABLE %@ %@", NAME, SCHEMA];
        [database executeUpdate:QUERY];
        NSLog(@"database.sql: %@", QUERY);
    }
    
    [database close];

    [task success: nil];
}

// Takes an array of objects. Each object contains a string "query", and array of strings ["args"]. If the write was succesfully executed, this call will return the affected ids within an array.
+ (void)writeAll:(ForgeTask *)task queries:(NSArray *)queryStrings {
    
    // Locate Documents directory and open database.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    
    if (![database open]) {
        [task error: @"ERROR: createTables() was unable to open or create a database."];
    }
    [database open];
    
    NSMutableArray *rowIds = [[NSMutableArray alloc] init];
    int lastInsertRowId = 0;
    
    for (NSDictionary *dataDict in queryStrings) {
        NSMutableArray *args = [dataDict objectForKey:@"args"];
        NSString *query = [dataDict objectForKey:@"query"];
        [database executeUpdate:query withArgumentsInArray:args];
        lastInsertRowId = [database lastInsertRowId];
        NSNumber *lastInsertRowIdInteger = [[NSNumber alloc] initWithInt:lastInsertRowId];
        [rowIds addObject:lastInsertRowIdInteger];
    }
    
    [database close];
    
    // Serialize array data into a JSON object.
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:rowIds
                                                       options:kNilOptions
                                                         error:nil];
    
    // JSONArray of JSON objects
    NSString *strData = [[NSString alloc]initWithData:JSONData encoding:NSUTF8StringEncoding];
    
    NSLog(@"database.sql: %@", strData);
    [task success: rowIds];
}

// Takes an array of queries and returns the resulting id's in an array.
+ (void)multiQuery:(ForgeTask *)task queries:(NSArray *)queries {
    
    // Locate Documents directory and open database.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    [database open];
    
    NSMutableArray *multiQueryResultsArray = [NSMutableArray array];
    
    for (id query in queries) {
        FMResultSet *resultsSet = [database executeQuery:query];
        NSMutableArray *queryResultsArray = [NSMutableArray array];
        while ([resultsSet next]) {
            [queryResultsArray addObject:[resultsSet resultDictionary]];
        }
        [multiQueryResultsArray addObject:queryResultsArray];
    }
    [database close];
    NSLog(@"Database.sql: %@", multiQueryResultsArray);
    [task success:multiQueryResultsArray];
}


// Returns the JSON array of objects that match the passed in sqlite query.
+ (void)query:(ForgeTask *)task query:(NSString *)query {
    
    // Error handling.
    if ([query length] == 0) {
        [task error: @"Error: Query is 0 characters long"];
        return;
    }
    
    // Locate Documents directory and open database.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    [database open];
    
    [ForgeLog d:[NSString stringWithFormat:@"sqlite database location: %@", path]];
    
    // Pop all query results into an NSMutableArray & close database.
    NSMutableArray *resultsArray = [NSMutableArray array];
    FMResultSet *resultsSet = [database executeQuery:query];
    while ([resultsSet next]) {
        [resultsArray addObject:[resultsSet resultDictionary]];
    }   
    [database close];
    
    // Serialize array data into a JSON object.
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:resultsArray
                                                       options:kNilOptions
                                                         error:nil];
    
    // JSONArray of JSON objects
    NSString *strData = [[NSString alloc]initWithData:JSONData encoding:NSUTF8StringEncoding];
    NSLog(@"Logging database.sql: %@", strData);
    
    [task success:resultsArray];
}

// Drops the given tables listed in an array of strings.
+ (void)dropTables:(ForgeTask *)task tables:(NSArray *)tables {
    // Locate Documents directory and open database.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *path = [docsPath stringByAppendingPathComponent:@"database.sqlite"];
    FMDatabase *database = [FMDatabase databaseWithPath:path];
    
    if (![database open]) {
        [task error: @"ERROR: createTables() was unable to open or create a database."];
    }
    
    [database open];
    
    // Iterate through the array and drop each table
    for (id item in tables) {
        NSString * query = [NSString stringWithFormat:@"DROP TABLE %@", item];
        [database executeUpdate:query];
        NSLog(@"database.sql: %@", query);
    }

    [database close];
    
    [task success: nil];
}

@end
