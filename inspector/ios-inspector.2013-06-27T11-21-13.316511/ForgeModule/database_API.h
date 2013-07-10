//
//  database_API.h
//  ForgeModule
//
//  Created by explhorak on 12/17/12.
//  Copyright (c) 2012 Trigger Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface database_API : NSObject

// Takes JSONArray that contains strings to construct the database schema
+ (void)createTables:(ForgeTask *)task schema:(NSArray *)schema;

// Takes array of JSON objects with one attribute called query (string), and args (array of strings - only ever be of length 1))
+ (void)writeAll:(ForgeTask *)task queries:(NSArray *)queryStrings;

// Returns the JSON array of note objects that match the passed in query.
+ (void)query:(ForgeTask *)task query:(NSString *)query;

// Returns an array of arrays 
+ (void)multiQuery:(ForgeTask *)task queries:(NSArray *)query;

// Just drops all the tables in database, given an array of tables
+ (void)dropTables:(ForgeTask *)task tables:(NSArray *)tables;

@end
