//
//  database_API.h
//  ForgeModule
//
//  Created by Alex Horak on 12/17/12.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface database_API : NSObject

+ (void)createTables:(ForgeTask *)task schema:(NSArray *)schema;

+ (void)writeAll:(ForgeTask *)task queries:(NSArray *)queryStrings;

+ (void)query:(ForgeTask *)task query:(NSString *)query;

+ (void)multiQuery:(ForgeTask *)task queries:(NSArray *)query;

+ (void)dropTables:(ForgeTask *)task tables:(NSArray *)tables;

@end
