//
//  DataBaseManager.h
//  Secure Windows App
//
//  Created by i-MaC on 10/15/16.
//  Copyright © 2016 Oneclick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <sqlite3.h>
@interface DataBaseManager : NSObject
{
    NSString *path;
	NSString* _dataBasePath;
	sqlite3 *_database;
	BOOL copyDb;
    BOOL ret;
    BOOL status;
    BOOL querystatus;
}
+(DataBaseManager*)dataBaseManager;
-(NSString*) getDBPath;
-(void)openDatabase;
-(BOOL)execute:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable;
-(BOOL)execute:(NSString*)sqlStatement;
-(int)executeSw:(NSString*)sqlStatement;


#pragma mark- ***************
-(NSInteger)getScalar:(NSString*)sqlStatement;
-(NSString*)getValue1:(NSString*)sqlStatement;

-(BOOL)updateMessage:(NSDictionary *)dictInfo with:(NSString *)user_id;
- (NSMutableArray *)getHistoryData;
-(BOOL)executeAddress:(NSString*)sqlQuery resultsArray:(NSMutableArray*)dataTable;
-(BOOL)updateQuery:(NSDictionary *)dictInfo with:(NSString *)user_id;

-(BOOL)Create_Geofence;
-(BOOL)Create_Geofence_Polygon;
-(BOOL)Create_Rules;
-(BOOL)Create_Actions_Table;
-(BOOL)Create_ActionInfo_Table;
-(BOOL)Create_RuleInfo_Table;
-(BOOL)createNewChatTable;
-(BOOL)CrateDiverMsgTable;


-(void)addcolumnsToInstallationTable;

-(void)saveVesselsintoDatabase:(NSMutableArray *)arrVessels;
-(void)addDeviceIdcolumnstoUnInstall;
-(void)addDeviceIdcolumnstoUnInspection;
-(void)addDeviceIdcolumnstoInstalls;
-(void)addPowerValuecolumnstoInstalls;
-(void)addActionValuescolumnstoInspection;
-(BOOL)Create_Extra_Vessel_Table;
-(void)SaveVesselinExtraTable:(NSMutableArray *)arrVessels;

-(void)addlocalOwnerSignscolumnstoInspection;
-(void)addServerOwnerSignscolumnstoInspection;
-(BOOL)recordExistOrNot:(NSString *)query;
-(BOOL)Create_Geofence_Alert_Table;
-(void)Add_sequence_to_NewChat;


@end







