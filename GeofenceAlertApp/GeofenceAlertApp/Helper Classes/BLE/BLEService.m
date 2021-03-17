//sc2 service uuid - {0x05, 0xb0, 0x4f, 0xb3, 0xf9, 0xE5, 0x08, 0xa7, 0xb2, 0x08, 0x43, 0x01, 0x00, 0xba, 0x00, 0x00}
//sc2 char uuid - {0x05, 0xb0, 0x4f, 0xb3, 0xf9, 0xE5, 0x08, 0xa7, 0xb2, 0x08, 0x43, 0x01, 0x01, 0xba, 0x00, 0x00}
//
//  BLEService.m
//
//
//  Created by Kalpesh Panchasara on 7/11/14.
//  Copyright (c) 2014 Kalpesh Panchasara, Ind. All rights reserved.
//
//{0x05, 0xb0, 0x4f, 0xb3, 0xf9, 0xE5, 0x08, 0xa7, 0xb2, 0x08, 0x43, 0x01, 0x00, 0xba, 0x00, 0x00}
//original---- 0000ba00-014308b2a708e5f9b34fb005
//from appp----0000AB00-0100-0800-0008-05F9B34FB000

#import "BLEService.h"
#import "BLEManager.h"

#import "AppDelegate.h"

#import "DataBaseManager.h"

#define TI_KEYFOB_LEVEL_SERVICE_UUID                        0x2A19
#define TI_KEYFOB_BATT_SERVICE_UUID                         0x180F
#define TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN                 1
#define TI_KEYFOB_PROXIMITY_ALERT_UUID                      0x1802
#define TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID             0x2a06

// 0x00, 0xb0, 0x4f, 0xb3, 0xf9, 0xE5, 0x08, 0x00, 0x00, 0x08, 0x43, 0x01, 0x01, 0xab, 0x00, 0x00 - track
// 0x05, 0xb0, 0x4f, 0xb3, 0xf9, 0xE5, 0x08, 0xa7, 0xb2, 0x08, 0x43, 0x01, 0x01, 0xba, 0x00, 0x00} - sc2
//0000ba01-0143-08b2-a708-E5F9B34FB005
//0000AB01-0143-0800-0008-E5F9B34FB000 - track
/*-----kp--------*/
#define CPTD_SERVICE_UUID_STRING                              @"0000ba00-0143-08b2-a708-e5f9b34fb005"
#define CPTD_CHARACTERISTIC_COMM_CHAR                         @"0000ba01-0143-08b2-a708-e5f9b34fb005"
#define CPTD_CHARACTERISTICS_DATA_CHAR                        @"0000AB01-0100-0800-0008-05F9B34FB000"

//0001D100AB0011E19B2300025B00A5A5

#define CKPTD_SERVICE_UUID_STRING                             @"0000D100-AB00-11E1-9B23-00025B00A5A5"
#define CKPTD_CHARACTERISTICS_DATA_CHAR                       @"0001D100-AB00-11E1-9B23-00025B00A5A5"
#define CKPTD_CHARACTERISTICS_DATA_CHAR1                      @"0002D100-AB00-11E1-9B23-00025B00A5A5"
#define CKPTD_CHARACTERISTICS_DATAAUTH                        @"0002D200-AB00-11E1-9B23-00025B00A5A5"
#define UUID_SMART_MESH_FACTORY_RESET_CHAR                    @"0003D100-AB00-11E1-9B23-00025B00A5A5" //0x0002D100AB0011E19B2300025B00A5A5

//#define CKPTD_SERVICE_UUID_STRING1                             @"0000AB00-0100-0800-0008-05F9B34FB000"
//#define CKPTD_CHARACTERISTICS_DATA_CHAR1                       @"0000AB02-0100-0800-0008-05F9B34FB000"
//
//#define CKPTD_SERVICE_UUID_STRING3                             @"0000AB00-0100-0800-0008-05F9B34FB000"
//#define CKPTD_CHARACTERISTICS_DATA_CHAR3                       @"0000AB03-0100-0800-0008-05F9B34FB000"
//
//#define CKPTD_SERVICE_UUID_STRING4                             @"0000AB00-0100-0800-0008-05F9B34FB000"
//#define CKPTD_CHARACTERISTICS_DATA_CHAR4                       @"0000ab04-0100-0800-0008-05F9B34FB000"

static BLEService    *sharedInstance    = nil;

@interface BLEService ()<CBPeripheralDelegate,AVAudioPlayerDelegate>
{
    NSMutableArray *assignedDevices;
    AVAudioPlayer *songAlarmPlayer1;
    BOOL isCannedMsg,isforAuth, isRadialTypeGeo;
}
@property (nonatomic, strong) CBPeripheral *servicePeripheral;
@property (nonatomic,strong) NSMutableArray *servicesArray;
@end

@implementation BLEService
@synthesize servicePeripheral;

#pragma mark- Self Class Methods
-(id)init{
    self = [super init];
    if (self) {
        //do additional work
    }
    return self;
}

+ (instancetype)sharedInstance
{
    if (!sharedInstance)
        sharedInstance = [[BLEService alloc] init];
    
    return sharedInstance;
}

-(id)initWithDevice:(CBPeripheral*)device andDelegate:(id /*<BLEServiceDelegate>*/)delegate{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
        [device setDelegate:self];
        //        [servicePeripheral setDelegate:self];
        servicePeripheral = device;
    }
    return self;
}

-(void)startDeviceService:(CBPeripheral *)kpb
{
    [servicePeripheral discoverServices:@[[CBUUID UUIDWithString:@"0000AB00-0100-0800-0008-05F9B34FB000"]]];
}

-(void) readDeviceBattery:(CBPeripheral *)device
{
    if (device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
        [self notification:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID p:device on:YES];
    }
}

-(void)readDeviceRSSI:(CBPeripheral *)device
{
    if (device.state == CBPeripheralStateConnected)
    {
        [device readRSSI];
    }
    else
    {
        return;
    }
}

-(void)startBuzzer:(CBPeripheral*)device
{
    if (device == nil || device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
        [self soundBuzzer:0x06 peripheral:device];
    }
}

-(void)stopBuzzer:(CBPeripheral*)device{
    if (device == nil || device.state != CBPeripheralStateConnected)
    {
        return;
    }
    else
    {
        [self soundBuzzer:0x07 peripheral:device];
    }
}

-(void) readAuthValuefromManager:(CBPeripheral *)peripherals;
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR];
    
    CBService *service = [self findServiceFromUUID:sUUID p:peripherals];
    
    if (!service)
    {
        //        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:sUUID],peripherals.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cUUID service:service];
    if (!characteristic)
    {
        //        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cUUID],[self CBUUIDToString:sUUID],peripherals.identifier.UUIDString);
        return;
    }
    [peripherals readValueForCharacteristic:characteristic];
}
-(void)EnableNotificationsForCommand:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}
-(void)EnableNotificationsForDATA:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}

#pragma mark- CBPeripheralDelegate
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray        *services    = nil;
    if (peripheral != servicePeripheral)
    {
        return ;
    }
    if (error != nil)
    {
        return ;
    }
    
    services = [peripheral services];
    if (!services || ![services count])
    {
        return ;
    }
    if (!error)
    {
//        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else
    {
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    NSArray        *characteristics    = [service characteristics];
//    NSLog(@"didDiscoverCharacteristicsForService %@",characteristics);
    CBCharacteristic *characteristic;
    
    if (peripheral != servicePeripheral) {
        //NSLog(@"didDiscoverCharacteristicsForService Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
        //NSLog(@"didDiscoverCharacteristicsForService Error %@\n", error);
        return ;
    }
    
    for (characteristic in characteristics)
    {
        UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
        
        switch(characteristicUUID){
            case TI_KEYFOB_LEVEL_SERVICE_UUID:
            {
                char batlevel;
                [characteristic.value getBytes:&batlevel length:1];
                if (_delegate) {
                    [_delegate activeDevice:peripheral];
                    NSString *battervalStr = [NSString stringWithFormat:@"%f",(float)batlevel];
//                    NSLog(@"battervalStr=====%@",battervalStr);
                    [_delegate batterySignalValueUpdated:peripheral withBattLevel:battervalStr];
                }
                //sending code to identify the from which app it has benn connected i.e, either Find App/others....
                [self soundBuzzer:0x0E peripheral:peripheral];
                
                //to know, from which OS the device has been connected i.e., iOS/Android
                [self soundBuzzer:0x0D peripheral:peripheral];
                break;
            }
        }
    }
}
#pragma mark- BLE send Notifications Here

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //Kalpesh here notification will come
    NSLog(@"<<<<<Kalpesh>>>>Recieved_from_Device>>%@",characteristic);
    NSString * strUUID = [NSString stringWithFormat:@"%@",characteristic.UUID];
    if ([strUUID isEqualToString:@"0000BA01-0143-08B2-A708-E5F9B34FB005"])//For Authentication 0000AB01-0143-0800-0008-E5F9B34FB000
    {
        NSData * valData = characteristic.value;
        NSString * valueStr = [NSString stringWithFormat:@"%@",valData.debugDescription];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@">" withString:@""];
        valueStr = [valueStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
        
        if (![[self checkforValidString:valueStr] isEqualToString:@"NA"])
        {
            if ([valueStr length]>=6)
            {
                NSString * strOpcode = [valueStr substringWithRange:NSMakeRange(0, 2)];
                if ([strOpcode isEqualToString:@"01"])
                {
                    NSString * strValue = [valueStr substringWithRange:NSMakeRange(4, 2)];
//                    NSLog(@"Key Value=%@",strValue);
                    NSString * strinfromHex = [self stringFroHex:strValue];
//                    NSLog(@"String from Hex Value=%@",strinfromHex);
                    NSInteger  valuInt = [self convertAlgo:[strinfromHex integerValue]];
//                    NSLog(@"Final Int Value=%ld",(long)valuInt);
                    
                    NSData * authData = [[NSData alloc] initWithBytes:&valuInt length:4];
                    
                    NSInteger opInt = 2;
                    NSData * opCodeData = [[NSData alloc] initWithBytes:&opInt length:1];
                    
                    NSInteger lengths = 4;
                    NSData * lengthData = [[NSData alloc] initWithBytes:&lengths length:1];
                    
                    NSMutableData * finalData = [opCodeData mutableCopy];
                    [finalData appendData:lengthData];
                    [finalData appendData:authData];
                    [self SendCommandNSData:finalData withPeripheral:peripheral];
                    NSLog(@"Wrote data for Authentication=%@",finalData);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthenticationCompleted" object:nil];
                }
                else if ([strOpcode isEqualToString:@"02"]) // Get GPS coordinates
                {
                    if (![[APP_DELEGATE checkforValidString:valueStr] isEqualToString:@"NA"])
                    {
                        if ([valueStr length]==20)
                        {
                            NSRange rangeFirst = NSMakeRange(4, 8);
                            NSString * strV1 = [NSString stringWithFormat:@"%f",[self getLatLongfromHex:[valueStr substringWithRange:rangeFirst]]];
                            rangeFirst = NSMakeRange(12, 8);
                            NSString * strV2 = [NSString stringWithFormat:@"%f",[self getLatLongfromHex:[valueStr substringWithRange:rangeFirst]]];
                            
                            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:strV1,@"lat", strV2, @"long", nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateCurrentGPSlocation" object:dict];
                        }
                    }
                }
                else if ([strOpcode isEqualToString:@"03"])
                {
                    NSString * strinfromHex = [self stringFroHex:valueStr];
                    NSDictionary * dict = [NSDictionary dictionaryWithObject:strinfromHex forKey:@"value"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUTCtime" object:dict];
                }
                else if ([[strOpcode lowercaseString] isEqualToString:@"a2"])//For Geofence Detail
                {
                    strOpcode = [valueStr substringWithRange:NSMakeRange(0, 4)];
                    if ([strOpcode isEqualToString:@"a201"])//First Packet
                    {
                        if([valueStr length] >= 24)
                        {
                            NSString * strID = [valueStr substringWithRange:NSMakeRange(6, 4)];
                            NSString * strSize = [self stringFroHex:[valueStr substringWithRange:NSMakeRange(10, 4)]];
                            NSString * strType = [valueStr substringWithRange:NSMakeRange(14, 2)];
                            NSString * strRadVetices = [self stringFroHex:[valueStr substringWithRange:NSMakeRange(16, 8)]];
                            [globalHomeVC SendFirstPacketToHomeVC:strID withSize:strSize withType:strType withRadius:strRadVetices];
                            if ([strType isEqualToString:@"00"])
                            {
                                isRadialTypeGeo = YES;
                            }
                            else
                            {
                                isRadialTypeGeo = NO;
                            }
                        }
                    }
                    else if ([strOpcode isEqualToString:@"a202"])//Second Packet
                    {
                        if([valueStr length] >= 22)
                        {
                            NSString * strLat = [valueStr substringWithRange:NSMakeRange(6, 8)];
                            NSString * strLong = [valueStr substringWithRange:NSMakeRange(14, 8)];
                            float latFloat =  ConverttoFloatfromHexadecimal(strLat);
                            float longFloat = ConverttoFloatfromHexadecimal(strLong);
                            if (isRadialTypeGeo == YES && [valueStr length] == 22)//Radial
                            {
                                [globalHomeVC SendSecondPacketLatLongtoHomeVC:latFloat withLongitude:longFloat];
                            }
                            else //Polygon
                            {
                                if([valueStr length] >= 38)
                                {
                                    float lat1 = ConverttoFloatfromHexadecimal([valueStr substringWithRange:NSMakeRange(6, 8)]);
                                    float lon1 = ConverttoFloatfromHexadecimal([valueStr substringWithRange:NSMakeRange(14, 8)]);
                                    float lat2 = ConverttoFloatfromHexadecimal([valueStr substringWithRange:NSMakeRange(22, 8)]);
                                    float lon2 = ConverttoFloatfromHexadecimal([valueStr substringWithRange:NSMakeRange(30, 8)]);
                                    NSString * strLat1 = [NSString stringWithFormat:@"%f", lat1];
                                    NSString * strLon1 = [NSString stringWithFormat:@"%f", lon1];
                                    NSString * strLat2 = [NSString stringWithFormat:@"%f", lat2];
                                    NSString * strLon2 = [NSString stringWithFormat:@"%f", lon2];
                                    NSDictionary * dict1 = [NSDictionary dictionaryWithObjectsAndKeys:strLat1,@"lat",strLon1,@"lon", nil];
                                    NSDictionary * dict2 = [NSDictionary dictionaryWithObjectsAndKeys:strLat2,@"lat",strLon2,@"lon", nil];
                                    NSMutableArray * arrLatLon = [[NSMutableArray alloc] init];
                                    [arrLatLon addObject:dict1];
                                    [arrLatLon addObject:dict2];
                                    [globalHomeVC PolygonLatLongtoHomeLatlonArray:arrLatLon];
                                }
                                else if([valueStr length] >= 22)
                                {
                                    float lat1 = ConverttoFloatfromHexadecimal([valueStr substringWithRange:NSMakeRange(6, 8)]);
                                    float lon1 = ConverttoFloatfromHexadecimal([valueStr substringWithRange:NSMakeRange(14, 8)]);
                                    NSString * strLat1 = [NSString stringWithFormat:@"%f", lat1];
                                    NSString * strLon1 = [NSString stringWithFormat:@"%f", lon1];
                                    NSDictionary * dict1 = [NSDictionary dictionaryWithObjectsAndKeys:strLat1,@"lat",strLon1,@"lon", nil];
                                    NSMutableArray * arrLatLon = [[NSMutableArray alloc] init];
                                    [arrLatLon addObject:dict1];
                                    [globalHomeVC PolygonLatLongtoHomeLatlonArray:arrLatLon];
                                }
                            }
                        }
                    }
                    else if ([strOpcode isEqualToString:@"a203"])//Third Packet
                    {
                        if([valueStr length] >= 24)// previosly it was 8
                        {
                            NSString * strLegth = [valueStr substringWithRange:NSMakeRange(4, 2)];
                            NSString * strGSMTime = [self stringFroHex:[valueStr substringWithRange:NSMakeRange(8, 8)]];
                            NSString * strIrridiumTime = [self stringFroHex:[valueStr substringWithRange:NSMakeRange(14, 8)]];
                            NSString * strRules = [valueStr substringWithRange:NSMakeRange(22, 2)];

                            [globalHomeVC ThirdPackettoHomeVC:strLegth withGSMTime:strGSMTime withIrridiumTime:strIrridiumTime withRuleId:strRules];
                        }
                    }
                    else if ([strOpcode isEqualToString:@"a204"]) // fourth packet
                    {
                        if ([valueStr length] >= 18)
                        {
                            NSString * strRlueID = [valueStr substringWithRange:NSMakeRange(6, 2)];
                            NSString * strValue = [self stringFroHex:[valueStr substringWithRange:NSMakeRange(8, 8)]];
                            NSString * strNoAction = @"NA";
                            [globalHomeVC FourthPacketToHomeVC:strRlueID withValue:strValue withNoOfAction:strNoAction];
                        }
                    }
                    else if ([strOpcode isEqualToString:@"a205"]) // fifth packet ---> Now fifth is end packate, 5th ignored
                    {
                        if([valueStr length] >= 6)
                        {
                            if ([[valueStr substringWithRange:NSMakeRange(4, 2)] isEqualToString:@"01"])
                            {
                                [globalHomeVC FifthPacketoHomeBLE]; 
                            }
                        }
                    }
                }
                else if ([[strOpcode lowercaseString] isEqualToString:@"a5"])//For Alert
                {
                    if ([valueStr length] >= 38)
                    {
                        if ([[valueStr substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"a511"])
                        {
                            if (![[valueStr substringWithRange:NSMakeRange(4, 28)] isEqualToString:@"00000000000000000000000000000000000"])
                            {
                                NSString * strGeoID = [valueStr substringWithRange:NSMakeRange(4, 4)];
                                NSString * strBreachType = [valueStr substringWithRange:NSMakeRange(8, 2)];
                                NSString * strRuleId = [valueStr substringWithRange:NSMakeRange(26, 2)];
                                NSString * strValue = [self stringFroHex:[valueStr substringWithRange:NSMakeRange(28, 8)]];
                                float lat = ConverttoFloatfromHexadecimal([valueStr substringWithRange:NSMakeRange(10, 8)]);
                                float lon = ConverttoFloatfromHexadecimal([valueStr substringWithRange:NSMakeRange(18, 8)]);
                                NSString * strLat = [NSString stringWithFormat:@"%f", lat];
                                NSString * strLon = [NSString stringWithFormat:@"%f", lon];

                                NSString * strFlag = [valueStr substringWithRange:NSMakeRange(36, 2)];
                                NSString * strPassID = [self stringFroHex:strGeoID];

                                NSMutableDictionary * dictData = [[NSMutableDictionary alloc] init];
                                [dictData setObject:strGeoID forKey:@"geofence_ID"];
                                [dictData setObject:strBreachType forKey:@"Breach_Type"];
                                [dictData setObject:strRuleId forKey:@"BreachRule_ID"];
                                [dictData setObject:strValue forKey:@"BreachRuleValue"];
                                [dictData setObject:strLat forKey:@"Breach_Lat"];
                                [dictData setObject:strLon forKey:@"Breach_Long"];
                                [dictData setObject:[NSString stringWithFormat:@"%@",peripheral.identifier] forKey:@"identifier"];

                                /*NSString *query  = [NSString stringWithFormat:@"select * from Geofence where geofence_ID = '%@'",strGeoID];
                                BOOL recordExist = [[DataBaseManager dataBaseManager] recordExistOrNot:query];*/
                                BOOL recordExist = YES;
                              if ([strFlag isEqualToString:@"01"])
                              {
                                    recordExist = NO;
                                    [self WritetoDevicetogetGeofenceDetail:strPassID];
                              }
                              else
                              {
                                  NSString *query  = [NSString stringWithFormat:@"select * from Geofence where geofence_ID = '%@'",strGeoID];
                                  BOOL recordExistcheck = [[DataBaseManager dataBaseManager] recordExistOrNot:query];
                                  if (recordExistcheck == NO)
                                  {
                                      recordExist = NO;
                                      [self WritetoDevicetogetGeofenceDetail:strPassID];
                                  }

                              }
                                if ([strRuleId isEqualToString:@"01"] || [strRuleId isEqualToString:@"02"])
                                {
                                }
                                else
                                {
                                    [globalHomeVC SendAlertInfoGeoID:dictData isGeoAvailable:recordExist];
                                }
                            }
                        }
                    }
                }
            }
        }
        isforAuth = NO;
    }
}
-(void)WritetoDevicetogetGeofenceDetail:(NSString *)strGeoID
{
    NSInteger intOpCode = [@"162" integerValue];
    NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpCode length:1];
    
    NSInteger intLength = [@"2" integerValue];
    NSData * dataLength = [[NSData alloc] initWithBytes:&intLength length:1];
    
    NSInteger intID = [strGeoID integerValue]; // for subbu its 1  ow its 2 intiD
    NSData * dataID = [[NSData alloc] initWithBytes:&intID length:2];
    
    NSMutableData *completeData = [dataOpcode mutableCopy];
    [completeData appendData:dataLength];
    [completeData appendData:dataID];
    NSLog(@"Wrote for Getting Geofence Detail---==%@",completeData);
    [self WriteValuestoSC2device:completeData with:globalPeripheral];
}
-(NSString *)GetRuleValueinDecimalfromHexaRule:(NSString *)strRule withValue:(NSString *)strValue
{
    NSString * strResult;
    if ([strRule isEqualToString:@"01"] || [strRule isEqualToString:@"02"])
    {
        [self stringFroHex:[strRule substringWithRange:NSMakeRange(16, 8)]];
    }
    
    return strResult;
}
-(double)getLatLongfromHex:(NSString *)strHex
{
    NSString *hexValueLat = strHex;
    int intConvertedLat = 0;
    NSScanner *firstScanner = [NSScanner scannerWithString:hexValueLat];
    [firstScanner scanHexInt:&intConvertedLat];
    NSLog(@"First: %d",intConvertedLat);
    int mIntLocationPrefix = intConvertedLat / 1000000;
    int mIntLocationPostfix = intConvertedLat % 1000000;
    NSLog(@"%d + %d",mIntLocationPrefix,mIntLocationPostfix);
    double mLongDouble = (double)mIntLocationPostfix /600000;
    NSLog(@"%f ",mLongDouble);
    double finalSol = mLongDouble + (double)mIntLocationPrefix;
    return finalSol;
}

-(void)SendOwnerdetails:(NSString *)ValueStr
{
    NSString * strValue = [ValueStr substringWithRange:NSMakeRange(4, [ValueStr length]-4)];
    NSMutableString * newString = [[NSMutableString alloc] init];
    int i = 0;
    while (i < [strValue length])
    {
        NSString * hexChar = [strValue substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [newString appendFormat:@"%c", (char)value];
        i+=2;
    }
    NSLog(@"Final inputs=%@",newString);
    NSDictionary * dict = [NSDictionary dictionaryWithObject:newString forKey:@"value"];

    if ([[ValueStr substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchedNamefromDevice" object:dict];
    }
    else if ([[ValueStr substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"02"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchedMobilefromDevice" object:dict];
    }
    else if ([[ValueStr substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"03"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchedEmail1fromDevice" object:dict];
    }
    else if ([[ValueStr substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"04"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchedEmail2fromDevice" object:dict];
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
//    NSLog(@"peripheralDidUpdateRSSI peripheral.name ==%@ ::RSSI ==%f, error==%@",peripheral.name,[peripheral.RSSI doubleValue],error);
    
    if (error == nil)
    {
        if(peripheral == nil)
            return;
        if (peripheral != servicePeripheral)
        {
            return ;
        }
        if (peripheral==servicePeripheral)
        {
            if (_delegate)
            {
                [_delegate updateSignalImage:[peripheral.RSSI doubleValue] forDevice:peripheral];
            }
            if (peripheral.state == CBPeripheralStateConnected)
            {
            }
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
//    NSLog(@"didReadRSSI peripheral.name ==%@ ::RSSI ==%f, error==%@",peripheral.name,[RSSI doubleValue],error);
    
    if(peripheral == nil)
        return;
    
    if (peripheral != servicePeripheral)
    {
        //NSLog(@"Wrong peripheral\n");
        return ;
    }
    
    if (peripheral==servicePeripheral)
    {
        
    }
}

#pragma mark - SEND COMMAND NSDATA WITH TOTAL BYTES
-(void)SendCommandNSData:(NSData *)data withPeripheral:(CBPeripheral *)peri
{
    if (peri != nil)
    {
        if (peri.state == CBPeripheralStateConnected)
        {
            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peri data:data];
        }
    }
}
#pragma mark - SYNC NAME WITH BLE DEVICE

-(void)SyncUserTextinfowithDevice:(NSString *)strName with:(CBPeripheral *)peripheral withOpcode:(NSString *)opcode
{
    NSString * str = [self hexFromStr:strName];
    NSData * msgData = [self dataFromHexString:str];
    
    
    NSInteger intLength = [strName length];
    NSData * lengthData = [[NSData alloc] initWithBytes:&intLength length:1];

    NSInteger intOpcode = [opcode integerValue];
    NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpcode length:1];

    NSMutableData *completeData = [dataOpcode mutableCopy];
    [completeData appendData:lengthData];
    [completeData appendData:msgData];

    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
}
-(void)writeUserUniqueValue:(NSString *)strName with:(CBPeripheral *)peripheral
{
    NSString * str = [self hexFromStr:strName];
    NSData * msgData = [self dataFromHexString:str];
    
    
    NSInteger intLength = [strName length];
    NSData * lengthData = [[NSData alloc] initWithBytes:&intLength length:1];
    
    NSInteger intOpcode = 10;
    NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpcode length:1];
    
    NSMutableData *completeData = [dataOpcode mutableCopy];
    [completeData appendData:lengthData];
    [completeData appendData:msgData];
    
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
}


#pragma mark - Sending Notification
-(void)sendSignals
{
    CBPeripheral * p;
    CBUUID * sUUID = [CBUUID UUIDWithString:@"0505A000D10211E19B2300025B002B2B"];
    CBUUID * cUUID = [CBUUID UUIDWithString:@"0505A001D10211E19B2300025B002B2B"];
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:p on:YES];
}
#pragma mark - Sending notifications
-(void)CBUUIDnotification:(CBUUID*)su characteristicUUID:(CBUUID*)cu p:(CBPeripheral *)p on:(BOOL)on
{
    
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        //isConnectionIssue = YES;
//        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
        //isConnectionIssue = YES;
        
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}

#pragma mark - Write value
-(void) CBUUIDwriteValue:(CBUUID *)su characteristicUUID:(CBUUID *)cu p:(CBPeripheral *)p data:(NSData *)data
{
    CBService *service = [self findServiceFromUUID:su p:p];
    
    
    if (!service) {
        //isConnectionIssue = YES;
//        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
        //isConnectionIssue = YES;
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    
//    NSLog(@" ***** find data *****%@",data);
//    NSLog(@" ***** find data *****%@",characteristic);
    
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}
#pragma mark  - send signal before Before
-(void)sendSignalBeforeBattery:(CBPeripheral *)kp withValue:(NSString *)dataStr
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
//            NSLog(@"continuousSendSignalToConnectedDevice %@ : 0x01",kp); // For battery
//            [self soundBuzzerforNotifydevice1:dataStr peripheral:kp];
        }
    }
}
#pragma mark  - send signals to device
-(void)sendBatterySignal:(CBPeripheral *)kp
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            double secsUtc1970 = [[NSDate date]timeIntervalSince1970];
            
            long long mills = (long long)([[NSDate date]timeIntervalSince1970]*1000.0);
//            NSLog(@"continuousSendSignalToConnectedDevice %lld : real time-%@",mills,[NSDate date]); // For battery
            
            NSString * setUTCTime = [NSString stringWithFormat:@"%f",secsUtc1970];
            [self soundbatteryToDevice:mills peripheral:kp];
        }
    }
}
-(void)sendDeviceType:(CBPeripheral *)kp withValue:(NSString *)dataStr
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
//            NSLog(@"continuousSendSignalToConnectedDevice %@ : 0x01",kp); // For battery
            //[self soundBuzzerforNotifydevice1:dataStr peripheral:kp];
            
            NSInteger test = [dataStr integerValue];
            
            //    buzzerValue = 01;
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];
            //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
            
            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
        }
    }
}
//15C8B50CF60
-(void)sendHandleString:(CBPeripheral *)peripheral
{
    Byte *bt =0x1F;
    NSData *d = [[NSData alloc] initWithBytes:&bt length:1];
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
}
-(void)sendingTestToDevice:(NSString *)message with:(CBPeripheral *)peripheral withIndex:(NSString *)strIndex
{
    NSString * str = [self hexFromStr:message];
    NSData * msgData = [self dataFromHexString:str];
    
    NSMutableData * midData = [[NSMutableData alloc] init];
    if ([strIndex length]>1)
    {
        for (int i=0; i<[strIndex length]; i++)
        {
            NSString * str = [strIndex substringWithRange:NSMakeRange(i,1)];
            NSString * string = [self hexFromStr:str];
            NSData * strData = [self dataFromHexString:string];
            [midData appendData:strData];
//            NSLog(@"strings===>>>%@",strData);
        }
    }
    else
    {
        NSString * str = [strIndex substringWithRange:NSMakeRange(0,1)];
        NSString * string = [self hexFromStr:str];
        NSData * strData = [self dataFromHexString:string];
        [midData appendData:strData];
        
    }
    NSString * dotStr = [self hexFromStr:@"."];
    NSData * dotData = [self dataFromHexString:dotStr];
    [midData appendData:dotData];
    
    NSInteger indexInt = [strIndex integerValue];
    NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
    
    NSMutableData *completeData = [indexData mutableCopy];
    [completeData appendData:midData];
    [completeData appendData:msgData];
    
    //    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING1];
    //    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
    //    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];
    
    /*NSString * str = [self hexFromStr:message];
     NSLog(@"%@", str);
     
     NSData *bytes = [self dataFromHexString:str];
     NSLog(@"This is sent data===>>>%@",bytes);
     
     NSInteger test = [strIndex integerValue];
     NSData *d = [[NSData alloc] initWithBytes:&test length:1];
     
     NSMutableData *completeData = [d mutableCopy];
     [completeData appendData:bytes];
     NSLog(@"This is sent data===>>>%@",completeData);
     
     //    NSData *d = [[NSData alloc] initWithBytes:0x1F length:1];
     CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING1];
     CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
     [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:completeData];*/
    
}



-(NSString*)hexFromStr:(NSString*)str
{
    NSData* nsData = [str dataUsingEncoding:NSUTF8StringEncoding];
    const char* data = [nsData bytes];
    NSUInteger len = nsData.length;
    NSMutableString* hex = [NSMutableString string];
    for(int i = 0; i < len; ++i)
        [hex appendFormat:@"%02X", data[i]];
    return hex;
}

- (NSData *)dataFromHexString:(NSString*)hexStr
{
    const char *chars = [hexStr UTF8String];
    int i = 0, len = hexStr.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}






-(void)sendNotifications:(CBPeripheral*)kp withType:(BOOL)isMulti withUUID:(NSString *)strUUID
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:YES];
}

-(void)sendNotificationsForOff:(CBPeripheral*)kp withType:(BOOL)isMulti
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATA_CHAR1];
    
    //    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
    kp.delegate = self;
    [self CBUUIDnotification:sUUID characteristicUUID:cUUID p:kp on:NO];
}


-(NSString *)getStringConvertedinUnsigned:(NSString *)strNormal
{
    NSString * strKey = strNormal;
    long ketLength = [strKey length]/2;
    NSString * strVal;
    for (int i=0; i<ketLength; i++)
    {
        NSRange range73 = NSMakeRange(i*2, 2);
        NSString * str3 = [strKey substringWithRange:range73];
        if ([strVal length]==0)
        {
            strVal = [NSString stringWithFormat:@" 0x%@",str3];
        }
        else
        {
            strVal = [strVal stringByAppendingString:[NSString stringWithFormat:@" 0x%@",str3]];
        }
    }
    return strVal;
}

-(void)sentAuthentication:(CBPeripheral *)kp withValue:(NSString *)dataStr // This is the method in which we can send value of Command like FF04 or 0004 sending as command before sending actual value
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            
            NSInteger test = [dataStr integerValue];
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];
            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATAAUTH];
            isforAuth=YES;
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
            
        }
    }
}
#pragma mark  - Method to send Command Values like FF04, 0004, 0001
-(void)sendCommandbeforeSendingValue:(CBPeripheral *)kp withValue:(NSString *)dataStr // This is the method in which we can send value of Command like FF04 or 0004 sending as command before sending actual value
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            
            NSInteger test = [dataStr integerValue];
            NSData *d = [[NSData alloc] initWithBytes:&test length:2];
            CBUUID * sUUID = [CBUUID UUIDWithString:CKPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CKPTD_CHARACTERISTICS_DATAAUTH];
            isforAuth=NO;
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
            
        }
    }
}
#pragma mark  - Method to send values and not command
-(void)sendBackAuth:(CBPeripheral *)kp withValue:(NSString *)dataStr //This method is using for writting value to ble device with data characteristics (Not Comman characteristics)
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSInteger test = [dataStr integerValue];
            NSData *d = [[NSData alloc] initWithBytes:&test length:4];//Lenght is 2 Bytes
            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:d];
            
        }
    }
}
-(NSString*)stringFroHex:(NSString *)hexStr
{
    unsigned long long startlong;
    NSScanner* scanner1 = [NSScanner scannerWithString:hexStr];
    [scanner1 scanHexLongLong:&startlong];
    double unixStart = startlong;
    NSNumber * startNumber = [[NSNumber alloc] initWithDouble:unixStart];
    return [startNumber stringValue];
}
-(NSInteger)convertAlgo:(NSInteger)originValue
{
    NSInteger final = ((((originValue * 75) + 8294) * 19) - (573*originValue + 989));
    return final;
}
-(NSInteger)AlgorithmforFactoryReset:(NSInteger)originValue
{
    NSInteger final = ((((originValue * 9) + 17) * 23) -((9*originValue) + 55));
    return final;
}

#pragma mark- Helper Methods
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2
{
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

-(const char *) CBUUIDToString:(CBUUID *) UUID
{
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}

-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service)
    {
        //        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic)
    {
        //        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}
-(UInt16) CBUUIDToInt:(CBUUID *) UUID
{
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}


-(void)MakeBuzzSound:(CBPeripheral *)kp
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSInteger opcodeInt = 7;
            NSData * indexData = [[NSData alloc] initWithBytes:&opcodeInt length:2];
            
            
            NSLog(@"Final data%@",indexData); // For battery
            
            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:indexData];
        }
    }
}
-(void)WriteValuestoSC2device:(NSData *)message with:(CBPeripheral *)peripheral
{
    CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
    CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
    [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:message];
}

-(void)SendCommandWithPeripheral:(CBPeripheral *)kp withValue:(NSString *)strValue
{
    if (kp != nil)
    {
        if (kp.state == CBPeripheralStateConnected)
        {
            NSInteger indexInt = [strValue integerValue];
            NSData * indexData = [[NSData alloc] initWithBytes:&indexInt length:1];
            
            
            NSLog(@"Final data%@",indexData); // For battery
            
            CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
            CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
            [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:kp data:indexData];
        }
    }
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
//Method to get sigend floating point from Hexadecimal
float ConverttoFloatfromHexadecimal(NSString *  strHex)
{
    const char * strCCC = [strHex UTF8String];

    uint32_t num;
    float f;
    sscanf(strCCC, "%x", &num);  // assuming you checked input
    f = *((float*)&num);
    printf("the hexadecimal 0x%08x becomes %.3f as a float\n", num, f);
    
    return f;
}

/*
#pragma mark- Helper Methods
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2
{
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

-(const char *) CBUUIDToString:(CBUUID *) UUID
{
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}

-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++)
    {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}

-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service)
    {
        [self moveToBridegeView];
        //        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        [self moveToBridegeView];
        //        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p
{
    for (int i=0; i < p.services.count; i++)
    {
        CBService *s = [p.services objectAtIndex:i];
        
        if ( self.servicesArray )
        {
            if ( ! [self.servicesArray containsObject:s.UUID] )
                [self.servicesArray addObject:s.UUID];
        }
        else
            self.servicesArray = [[NSMutableArray alloc] initWithObjects:s.UUID, nil];
        
        [p discoverCharacteristics:nil forService:s];
    }
    //    NSLog(@" services array is %@",self.servicesArray);
}

-(UInt16) CBUUIDToInt:(CBUUID *) UUID
{
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}
 #pragma mark - SoundBuzzer (Sending signals)
 -(void) soundBuzzer:(Byte)buzzerValue peripheral:(CBPeripheral *)peripheral
 {
 
 }
 #pragma mark - Sounder buzzer for notify device
 -(void)soundBuzzerforNotifydevice:(Byte)buzzerValue peripheral:(CBPeripheral *)peripheral
 {
 //    NSLog(@"buzzerValue==%d",buzzerValue);
 //    buzzerValue = 01;
 NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
 //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
 
 CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
 CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
 [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
 }
 -(void)soundBuzzerforNotifydevice1:(NSString *)buzzerValue peripheral:(CBPeripheral *)peripheral
 {
 //    NSLog(@"buzzerValue==%@",buzzerValue);
 NSInteger test = [buzzerValue integerValue];
 
 //    buzzerValue = 01;
 NSData *d = [[NSData alloc] initWithBytes:&test length:2];
 //    NSData *d = [[NSData alloc] initWithBytes:&buzzerValue length:2];
 
 CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
 CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTIC_COMM_CHAR];
 [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
 }
 #pragma mark - send Battery to device
 -(void) soundbatteryToDevice:(long long)buzzerValue peripheral:(CBPeripheral *)peripheral
 {
 //    NSInteger test = [buzzerValue integerValue];
 //    NSLog(@"test ==> %ld",(long)buzzerValue);
 NSData *d = [NSData dataWithBytes:&buzzerValue length:6];
 CBUUID * sUUID = [CBUUID UUIDWithString:CPTD_SERVICE_UUID_STRING];
 CBUUID * cUUID = [CBUUID UUIDWithString:CPTD_CHARACTERISTICS_DATA_CHAR];
 [self CBUUIDwriteValue:sUUID characteristicUUID:cUUID p:peripheral data:d];
 }
 
 
 -(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p {
 
 UInt16 s = [self swap:serviceUUID];
 UInt16 c = [self swap:characteristicUUID];
 NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
 NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
 CBUUID *su = [CBUUID UUIDWithData:sd];
 CBUUID *cu = [CBUUID UUIDWithData:cd];
 CBService *service = [self findServiceFromUUID:su p:p];
 if (!service)
 {
 //isConnectionIssue = YES;
 //        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
 return;
 }
 CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
 if (!characteristic)
 {
 //isConnectionIssue = YES;
 //        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
 return;
 }
 [p readValueForCharacteristic:characteristic];
 }
 
 -(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data
 {
 UInt16 s = [self swap:serviceUUID];
 UInt16 c = [self swap:characteristicUUID];
 NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
 NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
 CBUUID *su = [CBUUID UUIDWithData:sd];
 CBUUID *cu = [CBUUID UUIDWithData:cd];
 CBService *service = [self findServiceFromUUID:su p:p];
 if (!service) {
 //isConnectionIssue = YES;
 //        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
 return;
 }
 CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
 if (!characteristic)
 {
 //isConnectionIssue = YES;
 //        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@ \r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
 return;
 }
 
 //    NSLog(@" ***** find data *****%@",data);
 //    NSLog(@" ***** find data *****%@",characteristic);
 //    NSLog(@" ***** find data *****%@",data);
 
 [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
 }
 
 #pragma mark play Sound
 -(void)playSoundWhenDeviceRSSIisLow
 {
 // NSLog(@"IS_Range_Alert_ON==%@",IS_Range_Alert_ON);
 //if ([IS_Range_Alert_ON isEqualToString:@"YES"])
 {
 NSURL *songUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/beep.wav", [[NSBundle mainBundle] resourcePath]]];
 
 songAlarmPlayer1=[[AVAudioPlayer alloc]initWithContentsOfURL:songUrl error:nil];
 songAlarmPlayer1.delegate=self;
 
 AVAudioSession *audioSession1 = [AVAudioSession sharedInstance];
 NSError *err = nil;
 [audioSession1 setCategory :AVAudioSessionCategoryPlayback error:&err];
 [audioSession1 setActive:YES error:&err];
 
 [songAlarmPlayer1 prepareToPlay];
 [songAlarmPlayer1 play];
 }
 }
 
 -(void)stopPlaySound
 {
 [songAlarmPlayer1 stop];
 }
 

 */
@end

