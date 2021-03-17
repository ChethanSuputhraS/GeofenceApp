//
//  DataBaseManager.m
//  Secure Windows App
//
//  Created by i-MaC on 10/15/16.
//  Copyright © 2016 Oneclick. All rights reserved.
//

#import "DataBaseManager.h"
static DataBaseManager * dataBaseManager = nil;

@implementation DataBaseManager
#pragma mark - DataBaseManager initialization
-(id) init
{
    self = [super init];
	if (self)
    {
		// get full path of database in documents directory
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		path = [paths objectAtIndex:0];
		_dataBasePath = [path stringByAppendingPathComponent:@"Geotrack.sqlite"];
        
    NSLog(@"data base path:%@",_dataBasePath);
		[self openDatabase];
    }
	return self;
}
+(DataBaseManager*)dataBaseManager
{
    static dispatch_once_t _singletonPredicate;
    dispatch_once(&_singletonPredicate, ^{
        if (!dataBaseManager)
        {
            dataBaseManager = [[super alloc]init];
        }
    });
	return dataBaseManager;
}
-(void)checkDatabasetoCreate
{
    
}
- (NSString *) getDBPath
{
	
	//Search for standard documents using NSSearchPathForDirectoriesInDomains
	//First Param = Searching the documents directory
	//Second Param = Searching the Users directory and not the System
	//Expand any tildes and identify home directories.
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:@"Geotrack.sqlite"];
    
}
-(void)openDatabase
{
	BOOL ok;
	NSError *error;
	
	/*
	 * determine if database exists.
	 * create a file manager object to test existence
	 *
	 */
	NSFileManager *fm = [NSFileManager defaultManager]; // file manager
	ok = [fm fileExistsAtPath:_dataBasePath];
	
	// if database not there, copy from resource to path
	if (!ok)
    {
        // location in resource bundle
        NSString *appPath = [[[NSBundle mainBundle] resourcePath]
                             stringByAppendingPathComponent:@"Geotrack.sqlite"];
        if ([fm fileExistsAtPath:appPath])
        {
            // copy from resource to where it should be
            copyDb = [fm copyItemAtPath:appPath toPath:_dataBasePath error:&error];
            
            if (error!=nil)
            {
                copyDb = FALSE;
            }
            ok = copyDb;
        }
    }
    
    
    // open database
    if (sqlite3_open([_dataBasePath UTF8String], &_database) != SQLITE_OK)
    {
        sqlite3_close(_database); // in case partially opened
        _database = nil; // signal open error
    }
    
    if (!copyDb && !ok)
    { // first time and database not copied
        ok = [self Create_Geofence]; // create empty database
        if (ok)
        {
            // Populating Table first time from the keys.plist
            /*	NSString *pListPath = [[NSBundle mainBundle] pathForResource:@"ads" ofType:@"plist"];
             NSArray *contents = [NSArray arrayWithContentsOfFile:pListPath];
             for (NSDictionary* dictionary in contents) {
             
             NSArray* keys = [dictionary allKeys];
             [self execute:[NSString stringWithFormat:@"insert into ads values('%@','%@','%@')",[dictionary objectForKey:[keys objectAtIndex:0]], [dictionary objectForKey:[keys objectAtIndex:1]],[dictionary objectForKey:[keys objectAtIndex:2]]]];
             }*/
        }
    }
    
    if (!ok)
    {
        // problems creating database
        NSAssert1(0, @"Problem creating database [%@]",
                  [error localizedDescription]);
    }
    
}

#pragma mark - Create Installer Table
-(BOOL)Create_Geofence
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Geofence' ('id' INTEGER PRIMARY KEY  NOT NULL, 'name' VARCHAR, 'geofence_ID' VARCHAR, 'type' VARCHAR, 'lat' VARCHAR, 'long' VARCHAR, 'radiusOrvertices' VARCHAR ,'number_of_rules' VARCHAR, 'gsm_time' VARCHAR, 'irridium_time' VARCHAR, 'is_active' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)Create_Geofence_Polygon
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Polygon_Lat_Long' ('id' INTEGER PRIMARY KEY  NOT NULL, 'geofence_ID' VARCHAR, 'lat' VARCHAR, 'long' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
#pragma mark - Create Installer Table
-(BOOL)Create_Rules
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Rules_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'name' VARCHAR, 'geofence_ID' VARCHAR, 'rule_ID' VARCHAR, 'rule_value' VARCHAR, 'rule_number' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
#pragma mark - Create Installer Table
-(BOOL)Create_Actions_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Action_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'geofence_ID' VARCHAR, 'action_ID' VARCHAR, 'action_value' VARCHAR, 'RuleId' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
#pragma mark - Create  Table
-(BOOL)Create_ActionInfo_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Action_info_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'action' VARCHAR, 'action_ID' VARCHAR, 'description' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
#pragma mark - Create  Table
-(BOOL)Create_RuleInfo_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Rule_info_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'Rule' VARCHAR, 'Rule_ID' VARCHAR, 'description' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
#pragma mark - Create  Table
-(BOOL)Create_Geofence_Alert_Table
{
    int rc;
    
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:@"CREATE TABLE 'Geofence_alert_Table' ('id' INTEGER PRIMARY KEY  NOT NULL, 'geofence_ID' VARCHAR, 'Geo_name' VARCHAR, 'Geo_Type' VARCHAR, 'Breach_Type' VARCHAR, 'Breach_Lat' VARCHAR, 'Breach_Long' VARCHAR, 'BreachRule_ID' VARCHAR, 'BreachRuleValue' VARCHAR, 'date_Time' VARCHAR,'timeStamp' VARCHAR,'Rule_Name' VARCHAR,'is_Read' VARCHAR, 'OriginalRuleValue' VARCHAR, 'bleAddress' VARCHAR, 'Message' VARCHAR)",nil];
    
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            if (ret)
            {
                // statement built, execute
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)createNewChatTable
{
    int rc;
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"create table 'NewChat' (id integer primary key autoincrement not null,'from_name' varchar(255),'from_nano' varchar(255),'to_name' varchar(255),'to_nano' varchar(255),'msg_id' varchar(255),'msg_txt' varchar(255),'time' varchar(255),'status' varchar(255),'timeStamp' real)",nil];
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            //            //NSLog(@" create %@",sql);
            if (ret)
            {
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(BOOL)CrateDiverMsgTable
{
    int rc;
    // SQL to create new database
    NSArray* queries = [NSArray arrayWithObjects:
                        @"create table 'DiverMessage' (id integer primary key autoincrement not null,'Message' varchar(255) ,'is_emergency' varchar(255),'indexStr' varchar(255))",nil];
    if(queries != nil)
    {
        for (NSString* sql in queries)
        {
            sqlite3_stmt *stmt;
            rc = sqlite3_prepare_v2(_database, [sql UTF8String], -1, &stmt, NULL);
            ret = (rc == SQLITE_OK);
            //            //NSLog(@" create %@",sql);
            if (ret)
            {
                rc = sqlite3_step(stmt);
                ret = (rc == SQLITE_DONE);
                sqlite3_finalize(stmt); // free statement
                //sqlite3_reset(stmt);
            }
        }
    }
    return ret;
}
-(void)Add_sequence_to_NewChat
{
    sqlite3_stmt *createStmt = nil;
    
    NSString *query = [NSString stringWithFormat:@"ALTER TABLE NewChat ADD COLUMN sequence TEXT"];
    
    if (sqlite3_prepare_v2(_database, [query UTF8String], -1, &createStmt, NULL) == SQLITE_OK)
    {
        sqlite3_exec(_database, [query UTF8String], NULL, NULL, NULL);
    }
    else
    {
        NSLog(@"The Session table already exist in NewChat");
    }
    
    sqlite3_finalize(createStmt);
}
#pragma mark - Insert Query 
/*
 * Method to execute the simple queries
 */
-(BOOL)execute:(NSString*)sqlStatement
{
	sqlite3_stmt *statement = nil;
    status = FALSE;
	//NSLog(@"%@",sqlStatement);
	const char *sql = (const char*)[sqlStatement UTF8String];
    
	
	if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
       NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
       status = FALSE;
    }
    else
    {
        status = TRUE;
    }
	if (sqlite3_step(statement)!=SQLITE_DONE)
    {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
	}
    else
    {
        status = TRUE;
	}
	
	sqlite3_finalize(statement);
    return status;
}
-(int)executeSw:(NSString*)sqlStatement
{
    sqlite3_stmt *statement = nil;
    status = FALSE;
    //NSLog(@"%@",sqlStatement);
    const char *sql = (const char*)[sqlStatement UTF8String];
    
    
    if(sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    if (sqlite3_step(statement)!=SQLITE_DONE) {
        NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(_database));
        status = FALSE;
    } else {
        status = TRUE;
    }
    
    sqlite3_finalize(statement);
    NSInteger  returnValue = sqlite3_last_insert_rowid(_database);
    
    return returnValue;
}

#pragma mark - SQL query methods
/*
 * Method to get the data table from the database
 */
-(BOOL) execute:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable
{
    
    char** azResult = NULL;
    int nRows = 0;
    int nColumns = 0;
    querystatus = FALSE;
    char* errorMsg; //= malloc(255); // this is not required as sqlite do it itself
    const char* sql = [sqlQuery UTF8String];
    sqlite3_get_table(
                      _database,  /* An open database */
                      sql,     /* SQL to be evaluated */
                      &azResult,          /* Results of the query */
                      &nRows,                 /* Number of result rows written here */
                      &nColumns,              /* Number of result columns written here */
                      &errorMsg      /* Error msg written here */
                      );
	
    if(azResult != NULL)
    {
        nRows++; //because the header row is not account for in nRows
		
        for (int i = 1; i < nRows; i++)
        {
            NSMutableDictionary* row = [[NSMutableDictionary alloc]initWithCapacity:nColumns];
            for(int j = 0; j < nColumns; j++)
            {
                NSString*  value = nil;
                NSString* key = [NSString stringWithUTF8String:azResult[j]];
                if (azResult[(i*nColumns)+j]==NULL)
                {
                    value = [NSString stringWithUTF8String:[[NSString string] UTF8String]];
                }
                else
                {
                    value = [NSString stringWithUTF8String:azResult[(i*nColumns)+j]];
                }
				
                [row setValue:value forKey:key];
            }
            [dataTable addObject:row];
        }
        querystatus = TRUE;
        sqlite3_free_table(azResult);
    }
    else
    {
        NSAssert1(0,@"Failed to execute query with message '%s'.",errorMsg);
        querystatus = FALSE;
    }
    
    return 0;
}
-(NSInteger)getScalar:(NSString*)sqlStatement
{
	NSInteger count = -1;
	
	const char* sql= (const char *)[sqlStatement UTF8String];
	sqlite3_stmt *selectstmt;
	if(sqlite3_prepare_v2(_database, sql, -1, &selectstmt, NULL) == SQLITE_OK)
    {
		while(sqlite3_step(selectstmt) == SQLITE_ROW)
        {
			count = sqlite3_column_int(selectstmt, 0);
		}
	}
	sqlite3_finalize(selectstmt);
	
	return count;
}

-(NSString*)getValue1:(NSString*)sqlStatement
{
	
	NSString* value = nil;
	const char* sql= (const char *)[sqlStatement UTF8String];
	sqlite3_stmt *selectstmt;
	if(sqlite3_prepare_v2(_database, sql, -1, &selectstmt, NULL) == SQLITE_OK)
    {
		while(sqlite3_step(selectstmt) == SQLITE_ROW)
        {
			if ((char *)sqlite3_column_text(selectstmt, 0)!=nil)
            {
				value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 0)];
			}
		}
	}
	return value;
}

-(void)saveVesselsintoDatabase:(NSMutableArray *)arrVessels
{
   /* const char* query= (const char *)[@"INSERT INTO 'tbl_vessel_asset' ('vessel_succorfish_id','vessel_account_id','vessel_name','vessel_regi_no') VALUES (?, ?, ?, ?)" UTF8String];
    sqlite3_stmt *compiledStatement;

    
    sqlite3_exec(_database, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
    if(sqlite3_prepare(_database, query, -1, &compiledStatement, NULL) == SQLITE_OK)
    {
        for (NSMutableDictionary *obj in arrVessels)
        {
            sqlite3_bind_text(compiledStatement, 1, [[obj valueForKey:@"id"] UTF8String], -1, NULL);
            sqlite3_bind_text(compiledStatement, 2, [[obj valueForKey:@"accountId"] UTF8String], -1, NULL);
            sqlite3_bind_text(compiledStatement, 3, [[obj valueForKey:@"name"] UTF8String], -1, NULL);
            sqlite3_bind_text(compiledStatement, 4, [[obj valueForKey:@"regNo"] UTF8String], -1, NULL);

            if (sqlite3_step(compiledStatement) != SQLITE_DONE) NSLog(@"DB not updated. Error: %s",sqlite3_errmsg(_database));
            if (sqlite3_reset(compiledStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
        }
    }
    if (sqlite3_finalize(compiledStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
    if (sqlite3_exec(_database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
    sqlite3_close(_database); */
    
//    sqlite3_exec(_database, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
//    sqlite3_stmt *compiledStatement;
//    NSString * strQuery;
//    const char* sql= (const char *)[strQuery UTF8String];
//
//    if(sqlite3_prepare(_database, sql, -1, &compiledStatement, NULL) == SQLITE_OK)
//    {
//        for (NSDictionary *obj in arrVessels)
//        {
//            sqlite3_bind_text(compiledStatement, 1, [obj valueForKey:@"accountId"]);
//            sqlite3_bind_text(compiledStatement, 2, [obj valueForKey:@"accountId"]);
//            sqlite3_bind_text(compiledStatement, 2, [obj valueForKey:@"accountId"]);
//
//            if (sqlite3_step(compiledStatement) != SQLITE_DONE) NSLog(@"DB not updated. Error: %s",sqlite3_errmsg(_database));
//            if (sqlite3_reset(compiledStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
//        }
//    }
//    if (sqlite3_finalize(compiledStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
//    if (sqlite3_exec(db, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(_database));
//    sqlite3_close(_database);
    
   
    sqlite3_stmt *compiledStatement = NULL;
    char* errorMessage;
    sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    char buffer[] = "INSERT INTO 'tbl_vessel_asset' ('vessel_succorfish_id','vessel_account_id','vessel_name','vessel_regi_no') VALUES (?, ?, ?, ?)";
    sqlite3_stmt* stmt;
    sqlite3_prepare_v2(_database, buffer, strlen(buffer), &stmt, NULL);
    for (NSMutableDictionary *obj in arrVessels)
    {
        NSString * strIds = [self checkforValidString:[obj valueForKey:@"id"]];
        NSString * strAccountId = [self checkforValidString:[obj valueForKey:@"accountId"]];
        NSString * strName = [self checkforValidString:[obj valueForKey:@"name"]];
        NSString * strReg = [self checkforValidString:[obj valueForKey:@"regNo"]];

        sqlite3_bind_text(stmt, 1, [strIds UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [strAccountId UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [strName UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [strReg UTF8String], -1, NULL);

        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            printf("Commit Failed!\n");
        }
        sqlite3_reset(stmt);
    }
    sqlite3_exec(_database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
    sqlite3_finalize(stmt);
}
-(void)SaveVesselinExtraTable:(NSMutableArray *)arrVessels
{
    char* errorMessage;
    sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
    char buffer[] = "INSERT INTO 'tbl_vessel_extra' ('vessel_succorfish_id','vessel_account_id','vessel_name','vessel_regi_no') VALUES (?, ?, ?, ?)";
    sqlite3_stmt* stmt;
    sqlite3_prepare_v2(_database, buffer, strlen(buffer), &stmt, NULL);
    for (NSMutableDictionary *obj in arrVessels)
    {
        NSString * strIds = [self checkforValidString:[obj valueForKey:@"id"]];
        NSString * strAccountId = [self checkforValidString:[obj valueForKey:@"accountId"]];
        NSString * strName = [self checkforValidString:[obj valueForKey:@"name"]];
        NSString * strReg = [self checkforValidString:[obj valueForKey:@"regNo"]];
        
        sqlite3_bind_text(stmt, 1, [strIds UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [strAccountId UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [strName UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [strReg UTF8String], -1, NULL);
        
        if (sqlite3_step(stmt) != SQLITE_DONE)
        {
            printf("Commit Failed!\n");
        }
        sqlite3_reset(stmt);
    }
    sqlite3_exec(_database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
    sqlite3_finalize(stmt);
}
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"NA";
        }
    }
    else
    {
        strValid = @"NA";
    }
    strValid = [strValid stringByReplacingOccurrencesOfString:@"\"" withString:@""];

    return strValid;
}
-(BOOL)recordExistOrNot:(NSString *)query
{
        BOOL recordExist=NO;
        sqlite3_stmt *statement = nil;
    const char * sql = (const char*)[query UTF8String];
    
        if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) !=SQLITE_OK)
        {
            NSAssert1(0, @"Error while preparing  statement. '%s'", sqlite3_errmsg(_database));
            recordExist = NO;
        }
        else
        {
            if (sqlite3_step(statement)==SQLITE_ROW)
            {
                recordExist=YES;
            }
            sqlite3_finalize(statement);
        }
    return recordExist;
}

@end
