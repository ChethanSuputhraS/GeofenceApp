//
//  HomeVC.m
//  GeofenceAlertApp
//
//  Created by Ashwin on 7/16/20.
//  Copyright © 2020 srivatsa s pobbathi. All rights reserved.
//
#import "HomeCell.h"
#import "HomeVC.h"
#import "GeofencencAlertCell.h"
#import "ScandeviceVC.h"
#import "PolygonGeofenceVC.h"
#import "BLEService.h"
#import "HistoryVC.h"
#import "FCAlertView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "RadialGeofenceVC.h"

#if __has_feature(objc_arc)
  #define DLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#else
  #define DLog(format, ...) CFShow([NSString stringWithFormat:format, ## __VA_ARGS__]);
#endif

@interface HomeVC()<UITableViewDelegate,UITableViewDataSource,FCAlertViewDelegate,CBCentralManagerDelegate>
{
    NSMutableArray * arrGeofence,* arrActons, * arrPolygon, * arrRules;
    CBCentralManager*centralManager;
    NSTimer * connectionTimer, * advertiseTimer;;
    CBPeripheral * classPeripheral;
    NSMutableDictionary * currentAlertDict, * waitDict;
    int historyCount;
    FCAlertView * geofenceAlertPopup;
}
@end

@implementation HomeVC

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = true;
    
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    [self setNavigationViewFrames];
    
    arrGeofence = [[NSMutableArray alloc]init];
    NSString * str = [NSString stringWithFormat:@"Select * from Geofence"];
    [[DataBaseManager dataBaseManager] execute:str resultsArray:arrGeofence];
    NSLog(@"<----==Geofence Arr--==%@",arrGeofence);
    globalDict = [[NSMutableDictionary alloc] init];
    arrActons = [[NSMutableArray alloc] init];
    arrPolygon = [[NSMutableArray alloc] init];
    arrGlobalDevices = [[NSMutableArray alloc] init];
    arrRules = [[NSMutableArray alloc] init];
    currentAlertDict = [[NSMutableDictionary alloc] init];

    [advertiseTimer invalidate];
    advertiseTimer = nil;
    advertiseTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(AdvertiseTimerMethod) userInfo:nil repeats:NO];

    [APP_DELEGATE endHudProcess];
    [APP_DELEGATE startHudProcess:@"Scanning..."];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self InitialBLE];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AuthenticationCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AuthenticationCompleted:) name:@"AuthenticationCompleted" object:nil];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [APP_DELEGATE showTabBar:self.tabBarController];
    [super viewWillAppear:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateUTCtime" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateCurrentGPSlocation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AuthenticationCompleted" object:nil];
    [super viewWillDisappear:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    int yy = 44;
    if (IS_IPHONE_X)
    {
        yy = 44;
    }

    UIImageView * imgLogo = [[UIImageView alloc] init];
    imgLogo.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgLogo.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgLogo.userInteractionEnabled = YES;
    [self.view addSubview:imgLogo];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy + globalStatusHeight)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, globalStatusHeight, DEVICE_WIDTH-100, yy)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Geofence"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    
    UIButton *btnhistory=[[UIButton alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-60, globalStatusHeight-10, 60, 60)];
    btnhistory.backgroundColor = UIColor.clearColor;
    btnhistory.clipsToBounds = true;
    [btnhistory setImage:[UIImage imageNamed:@"history.png"] forState:UIControlStateNormal];
    [btnhistory addTarget:self action:@selector(btnHistoyClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnhistory];
    
    lblBadgeHistry = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-25, globalStatusHeight, 20, 20)];
    lblBadgeHistry.backgroundColor = UIColor.redColor;
    lblBadgeHistry.layer.cornerRadius = 10;
    lblBadgeHistry.clipsToBounds = true;
//    lblBadgeHistry.text = @"20";
    lblBadgeHistry.font = [UIFont fontWithName:CGBold size:12];
    lblBadgeHistry.textColor = UIColor.whiteColor;
    lblBadgeHistry.textAlignment = NSTextAlignmentCenter;
    lblBadgeHistry.hidden = true;
    [viewHeader addSubview:lblBadgeHistry];

    UIButton * btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRefresh setFrame:CGRectMake(10, globalStatusHeight-10, 60, 60)];
    btnRefresh.backgroundColor = UIColor.clearColor;
    [btnRefresh setImage:[UIImage imageNamed:@"reload.png"] forState:UIControlStateNormal];
    [btnRefresh addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnRefresh];
    
    tblDeviceList = [[UITableView alloc] initWithFrame:CGRectMake(0, yy+globalStatusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yy)];
    tblDeviceList.delegate = self;
    tblDeviceList.dataSource= self;
    tblDeviceList.backgroundColor = UIColor.clearColor;
    tblDeviceList.separatorStyle = UITableViewCellSelectionStyleNone;
    [tblDeviceList setShowsVerticalScrollIndicator:NO];
    tblDeviceList.backgroundColor = [UIColor clearColor];
    tblDeviceList.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblDeviceList.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:tblDeviceList];
    
    topPullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblDeviceList withClient:self];
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];
    
    yy = yy+30;
    
    lblScanning = [[UILabel alloc] initWithFrame:CGRectMake((DEVICE_WIDTH/2)-50, yy, 100, 44)];
    [lblScanning setBackgroundColor:[UIColor clearColor]];
    [lblScanning setText:@"Scanning..."];
    [lblScanning setTextAlignment:NSTextAlignmentCenter];
    [lblScanning setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblScanning setTextColor:[UIColor whiteColor]];
    lblScanning.hidden = true;
    [self.view addSubview:lblScanning];

    lblNoDevice = [[UILabel alloc]initWithFrame:CGRectMake(30, (DEVICE_HEIGHT/2)-90, (DEVICE_WIDTH)-60, 100)];
    lblNoDevice.backgroundColor = UIColor.clearColor;
    [lblNoDevice setTextAlignment:NSTextAlignmentCenter];
    [lblNoDevice setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
    [lblNoDevice setTextColor:[UIColor whiteColor]];
    lblNoDevice.text = @"No Devices Found.";
    [self.view addSubview:lblNoDevice];
}
#pragma mark- UITableView Methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{
    if (tableView == tblDeviceList)
    {
        UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-146, 55)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel *lblmenu=[[UILabel alloc]init];
        lblmenu.text = @"   Tap on Connect button to pair with device";
        [lblmenu setTextColor:[UIColor whiteColor]];
        [lblmenu setFont:[UIFont fontWithName:CGRegular size:textSize-1]];
        lblmenu.frame = CGRectMake(0,0, DEVICE_WIDTH, 45);
        lblmenu.backgroundColor = UIColor.blackColor;
        [headerView addSubview:lblmenu];
        return headerView;
    }
    return [UIView new];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 55;
}
#pragma mark- UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BLEManager sharedManager] foundDevices] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellReuseIdentifier = @"cellIdentifier";
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (cell == nil)
    {
        cell = [[HomeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier];
    }
    cell.lblConnect.text= @"Connect";
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];
    if ([[[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"name"] isEqualToString:@"log"])
    {
        cell.lblDeviceName.text = [[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"name"];
        cell.lblAddress.text = [[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"bleAddress"];
        cell.lblConnect.text = @" ";
    }
    else
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        if (p.state == CBPeripheralStateConnected)
        {
            cell.lblConnect.text= @"Disconnect";
        }
        cell.lblDeviceName.text = [[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"name"];
        cell.lblAddress.text = [[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"bleAddress"];
    }
    
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * arrayDevices = [[NSMutableArray alloc] init];
    arrayDevices =[[BLEManager sharedManager] foundDevices];

    if ([arrayDevices count]>0)
    {
        CBPeripheral * p = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"peripheral"];
        if (p.state == CBPeripheralStateConnected)
        {
            [APP_DELEGATE startHudProcess:@"Disconnecting..."];
            [[BLEManager sharedManager] disconnectDevice:p];
        }
        else
        {
            [connectionTimer invalidate];
            connectionTimer = nil;
            connectionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(ConnectionTimeOutMethod) userInfo:nil repeats:NO];

//            strBleAddress = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"bleAddress"];
            isConnectedtoAdd = YES;
            classPeripheral = p;
            [APP_DELEGATE startHudProcess:@"Connecting..."];
            [[BLEManager sharedManager] connectDevice:p];
        }
    }
}
#pragma mark - MEScrollToTopDelegate Methods
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [topPullToRefreshManager tableViewScrolled];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y >=360.0f)
    {
    }
    else
        [topPullToRefreshManager tableViewReleased];
}
- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager
{
    [self performSelector:@selector(stoprefresh) withObject:nil afterDelay:1.5];
}
-(void)stoprefresh
{
    [self refreshBtnClick];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
}
-(void)btnHistoyClick
{
    lblBadgeHistry.hidden = true;
    
    globalHistoryVC = [[HistoryVC alloc] init];
    [self.navigationController pushViewController:globalHistoryVC animated:true];
    
    
//    [self setupAlertView];
    
//    NSString * strGeo = @"delete from Geofence";
//    NSString * strAction = @"delete from Action_Table";
//    NSString * strRule = @"delete from Rules_Table";
//    [[DataBaseManager dataBaseManager] execute:strGeo];
//    [[DataBaseManager dataBaseManager] execute:strAction];
//    [[DataBaseManager dataBaseManager] execute:strRule];

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
// css add this
-(void)refreshBtnClick
{
    [[[BLEManager sharedManager] foundDevices] removeAllObjects];
    [[BLEManager sharedManager] rescan];
    [tblDeviceList reloadData];
    
    NSArray * tmparr = [[BLEManager sharedManager]getLastConnected];
    for (int i=0; i<tmparr.count; i++)
    {
        CBPeripheral * p = [tmparr objectAtIndex:i];
        NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",p.identifier];
        if ([[arrGlobalDevices valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
        {
            NSInteger  foudIndex = [[arrGlobalDevices valueForKey:@"identifier"] indexOfObject:strCurrentIdentifier];
            if (foudIndex != NSNotFound)
            {
                if ([arrGlobalDevices count] > foudIndex)
                {
                    if (![[[[BLEManager sharedManager] foundDevices] valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
                    {
                        [[[BLEManager sharedManager] foundDevices] addObject:[arrGlobalDevices objectAtIndex:foudIndex]];
                    }
                }
            }
        }
    }
    if ( [[[BLEManager sharedManager] foundDevices] count] >0)
    {
        tblDeviceList.hidden = false;
        lblNoDevice.hidden = true;
        [advertiseTimer invalidate];
        advertiseTimer = nil;
        [tblDeviceList reloadData];
    }
    else
    {
        tblDeviceList.hidden = true;
        lblNoDevice.hidden = false;
        [advertiseTimer invalidate];
        advertiseTimer = nil;
        advertiseTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(AdvertiseTimerMethod) userInfo:nil repeats:NO];
    }
}
#pragma mark- AlertView
-(void)setupAlertView:(NSString *)strErrorMsg withTitle:(NSString *)strTitle withDict:(NSMutableDictionary *)detailDict
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *app=[UIApplication sharedApplication];
        if (app.applicationState == UIApplicationStateBackground)
        {
            NSLog(@"We are in the background Disconnect");
            UIUserNotificationSettings *notifySettings=[[UIApplication sharedApplication] currentUserNotificationSettings];
            if ((notifySettings.types & UIUserNotificationTypeAlert)!=0)
            {
                globalBadgeCount = globalBadgeCount+1;
                [UIApplication sharedApplication].applicationIconBadgeNumber = globalBadgeCount;

                UILocalNotification *notification=[UILocalNotification new];
                notification.soundName = @"alert_alarm.mp3";
                notification.alertBody= strErrorMsg;
                [app presentLocalNotificationNow:notification];
            }
        }
    });
    
    historyCount = historyCount+1;
    lblBadgeHistry.hidden = false;
    lblBadgeHistry.text = [NSString stringWithFormat:@"%d",historyCount];
    
    [geofenceAlertPopup removeFromSuperview];
    geofenceAlertPopup = [[FCAlertView alloc] init];
    geofenceAlertPopup.colorScheme = [UIColor blackColor];
    geofenceAlertPopup.detailsDict = detailDict;
    [geofenceAlertPopup makeAlertTypeCaution];
     [geofenceAlertPopup addButton:@"Seen in Map" withActionBlock:^
     { // see in map action here
         NSLog(@"This alert's Data =%@",detailDict);
         
         self->historyCount = self->historyCount - 1;
         
         if (globalBadgeCount <= 0)
         {
             self->historyCount = 0;
             self->lblBadgeHistry.hidden = true;
             self->lblBadgeHistry.text = [NSString stringWithFormat:@"0"];
         }
         else
         {
             self->lblBadgeHistry.hidden = false;
             self->lblBadgeHistry.text = [NSString stringWithFormat:@"%d",self->historyCount];
         }
         
         if ([[detailDict valueForKey:@"Geo_Type"] isEqualToString:@"00"])
         {
             RadialGeofenceVC *view1 = [[RadialGeofenceVC alloc]init];
             view1.isfromEdit = YES;
             view1.isfromHistory = NO;
             view1.dictGeofenceInfo = detailDict;
             [self.navigationController pushViewController:view1 animated:true];
         }
         else
         {
             PolygonGeofenceVC *view1 = [[PolygonGeofenceVC alloc]init];
             view1.isfromEdit = YES;
             view1.isfromHistory = NO;
             view1.dictGeofenceInfo = detailDict;
             [self.navigationController pushViewController:view1 animated:true];
         }
     }];
     geofenceAlertPopup.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:textSize];
         geofenceAlertPopup.delegate = self;
    [geofenceAlertPopup showAlertWithTitle:strTitle withSubtitle:strErrorMsg withCustomImage:[UIImage imageNamed:@"alert-round.png"] withDoneButtonTitle:@"Ignore" andButtons:nil];
     [geofenceAlertPopup setAlertSoundWithFileName:@"alert_alarm.mp3"];
}
#pragma mark - Timer Methods
-(void)ConnectionTimeOutMethod
{
    if (classPeripheral.state == CBPeripheralStateConnected)
    {
    }
    else
    {
        if (classPeripheral == nil)
        {
            return;
        }
        [APP_DELEGATE endHudProcess];
        
        URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Something went wrong. Please try again later." cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
        [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
        [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
            [alertView hideWithCompletionBlock:^{}];
        }];
        [alertView showWithAnimation:URBAlertAnimationTopToBottom];
        if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
    }
}
-(void)AdvertiseTimerMethod
{
    [APP_DELEGATE endHudProcess];
    if ( [[[BLEManager sharedManager] foundDevices] count] >0){
        self->tblDeviceList.hidden = false;
        self->lblNoDevice.hidden = true;
        [self->tblDeviceList reloadData];
    }
    else
    {
        self->tblDeviceList.hidden = true;
        self->lblNoDevice.hidden = false;
    }
        [self->tblDeviceList reloadData];
}
#pragma mark - BLE Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (@available(iOS 10.0, *)) {
        if (central.state == CBManagerStatePoweredOff)
        {
            [APP_DELEGATE endHudProcess];
            [self GlobalBLuetoothCheck];
        }
    } else
    {
        
    }
}
-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotifiyDiscoveredDevices" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeviceDidDisConnectNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotifiyDiscoveredDevices:) name:@"NotifiyDiscoveredDevices" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidConnectNotification:) name:@"DeviceDidConnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDidDisConnectNotification:) name:@"DeviceDidDisConnectNotification" object:nil];
}
-(void)NotifiyDiscoveredDevices:(NSNotification*)notification//Update peripheral
{
dispatch_async(dispatch_get_main_queue(), ^(void){
    
    if ( [[[BLEManager sharedManager] foundDevices] count] >0){
        self->tblDeviceList.hidden = false;
        self->lblNoDevice.hidden = true;
        [self->tblDeviceList reloadData];
        [self->advertiseTimer invalidate];
        self->advertiseTimer = nil;
        [APP_DELEGATE endHudProcess];
    }
    else{
        self->tblDeviceList.hidden = true;
        self->lblNoDevice.hidden = false;}
        [self->tblDeviceList reloadData];});
}
-(void)DeviceDidConnectNotification:(NSNotification*)notification//Connect periperal
{
dispatch_async(dispatch_get_main_queue(), ^(void){
    [APP_DELEGATE endHudProcess];
    [self->tblDeviceList reloadData];
});
}

-(void)DeviceDidDisConnectNotification:(NSNotification*)notification//Disconnect periperal
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [[[BLEManager sharedManager] foundDevices] removeAllObjects];
        [[BLEManager sharedManager] rescan];
        [self->tblDeviceList reloadData];
        [APP_DELEGATE endHudProcess];});
}
-(void)AuthenticationCompleted:(NSNotification *)notify
{
    globalPeripheral = classPeripheral;
  //  [globalHomeVC WritetoDevicetogetGeofenceDetail:@"NA"];
    NSMutableArray * tmpArr = [[BLEManager sharedManager] foundDevices];
    if ([[tmpArr valueForKey:@"peripheral"] containsObject:classPeripheral])
    {
        NSInteger  foudIndex = [[tmpArr valueForKey:@"peripheral"] indexOfObject:classPeripheral];
        if (foudIndex != NSNotFound)
        {
            if ([tmpArr count] > foudIndex)
            {
                NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",classPeripheral.identifier];
                NSString * strName = [[tmpArr  objectAtIndex:foudIndex]valueForKey:@"name"];
                NSString * strAddress = [[tmpArr  objectAtIndex:foudIndex]valueForKey:@"bleAddress"];

                if (![[arrGlobalDevices valueForKey:@"identifier"] containsObject:strCurrentIdentifier])
                {
                    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:strCurrentIdentifier,@"identifier",classPeripheral,@"peripheral",strName,@"name",strAddress,@"bleAddress", nil];
                    [arrGlobalDevices addObject:dict];
                }
            }
        }
    }
}

-(void)GlobalBLuetoothCheck
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Geofence Alert" message:@"Please turn on Bluetooth to access the App." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:true completion:nil];
}
-(void)WritetoDevicetogetGeofenceDetail:(NSString *)strGeoID
{
    globalPeripheral = classPeripheral;
//    [[BLEService sharedInstance] SendCommandWithPeripheral:globalPeripheral withValue:@"162"];//To send 0xa2 to fetch geofence

    NSInteger intOpCode = [@"162" integerValue];
    NSData * dataOpcode = [[NSData alloc] initWithBytes:&intOpCode length:1];
    
    NSInteger intLength = [@"2" integerValue];
    NSData * dataLength = [[NSData alloc] initWithBytes:&intLength length:1];
    
    NSInteger intID = [@"1" integerValue]; // for subbu its 1  ow its 2 intiD
    NSData * dataID = [[NSData alloc] initWithBytes:&intID length:2];
    
    NSMutableData *completeData = [dataOpcode mutableCopy];
    [completeData appendData:dataLength];
    [completeData appendData:dataID];
    NSLog(@"Wrote for Getting Geofence Detail---==%@",completeData);
    [[BLEService sharedInstance] WriteValuestoSC2device:completeData with:globalPeripheral];
}

#pragma mark - Recieving Packet from Device

-(void)SendFirstPacketToHomeVC:(NSString *)strID withSize:(NSString *)strSize withType:(NSString *)strType  withRadius:(NSString *)strRadius;
{
    NSLog(@"=First Packet ID====>%@, SIZE ==%@, TYPE==%@, RADIUS ==%@",strID, strSize, strType, strRadius);
    [globalDict setValue:strID forKey:@"GeofenceID"];
    [globalDict setValue:strSize forKey:@"GeofenceSize"];
    [globalDict setValue:strType forKey:@"GeofenceType"];
    [globalDict setValue:strRadius forKey:@"radiusOrvertices"];
}
-(void)SendSecondPacketLatLongtoHomeVC:(float)latitude withLongitude:(float)longitude
{
    NSLog(@"=Second Packet Lat====>%f Long==%f",latitude, longitude);
  
    [globalDict setValue:[NSNumber numberWithFloat:latitude] forKey:@"Latitude"];
    [globalDict setValue:[NSNumber numberWithFloat:longitude] forKey:@"Longitude"];
}
-(void)ThirdPackettoHomeVC:(NSString *)strLength withGSMTime:(NSString *)strGsmTime withIrridiumTime:(NSString *)strIrridmTime withRuleId:(NSString *)strRuleId
{
    NSLog(@"=Third packet No.of Rules=>%@",strRuleId);
    [globalDict setValue:strLength forKey:@"PacketLength"];
    [globalDict setValue:strRuleId forKey:@"NoRules"];
    [globalDict setValue:strGsmTime forKey:@"GSMtime"];
    [globalDict setValue:strIrridmTime forKey:@"IrridiumTime"];

}
-(void)FourthPacketToHomeVC:(NSString *)strruleID withValue:(NSString *)strValue withNoOfAction:(NSString *)strNoAction
{
    NSLog(@"=Fourth Packet Rule ID=>%@  RuleValue==%@  No.of Action-==%@",strruleID, strValue, strNoAction);
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    [dict setValue:strruleID forKey:@"RuleID"];
    [dict setValue:strValue forKey:@"Value"];
    [dict setValue:strNoAction forKey:@"NoAction"];
    [arrRules addObject:dict];
}
-(void)FifthPockeToHome:(NSMutableArray *)arrFithPacktData
{
    NSLog(@"=Fifth Packet Array=>%@",arrFithPacktData);
    for (int i=0 ; i<[arrFithPacktData count]; i++)
    {
        [arrActons addObject:[arrFithPacktData objectAtIndex:i]];
    }
}
-(void)PolygonLatLongtoHomeLatlonArray:(NSMutableArray *)arrLatLong
{
    NSLog(@"Polygon Packet Array=>%@",arrLatLong);
    for (int i=0 ; i<[arrLatLong count]; i++)
    {
        [arrPolygon addObject:[arrLatLong objectAtIndex:i]];
    }
}
-(void)FifthPacketoHomeBLE //
{
    NSLog(@"=Sixth Packet =>");
    [self InsertToDataBase];

    dispatch_async(dispatch_get_main_queue(), ^(void)
           {
        if (self->waitDict != nil)
        {
            [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(ShowDelayedPopup:) userInfo:self->waitDict repeats:NO];
        }
  });
}
-(NSString *)getRuleNamefromRuleId:(NSString *)strRuleId
{
    NSString * strRuleName = @"NA";
    if ([strRuleId isEqualToString:@"03"])
    {
        strRuleName = @"Breach Minimum Dwell Time";
    }
    else if ([strRuleId isEqualToString:@"04"])
    {
        strRuleName = @"Breach Maximum Dwell Time";
    }
    else if ([strRuleId isEqualToString:@"05"])
    {
        strRuleName = @"Breach Minimum Speed limit";
    }
    else if ([strRuleId isEqualToString:@"06"])
    {
        strRuleName = @"Breach Maximum Speed limit";
    }
    else if ([strRuleId isEqualToString:@"07"])
    {
        strRuleName = @"Boundry Cross Violation";
    }
    return strRuleName;
}
-(void)SendAlertInfoGeoID:(NSMutableDictionary *)dataDict isGeoAvailable:(BOOL)isAvail;
{
    currentAlertDict = [[NSMutableDictionary alloc] init];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSNumber *timeStampObj = [NSNumber numberWithInteger: timeStamp];
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"dd-MM-yyyy hh:mm:ss"];
    [DateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC+5:30"]];
    
    NSString * currentDateAndTime = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:[NSDate date]]];
    NSString * strTimeStamp = [NSString stringWithFormat:@"%@",timeStampObj];

    [dataDict setObject:currentDateAndTime forKey:@"date_Time"];
    [dataDict setObject:strTimeStamp forKey:@"timeStamp"];

    NSString * strFoundIdentifier = [dataDict valueForKey:@"identifier"];
    if ([[arrGlobalDevices valueForKey:@"identifier"] containsObject:strFoundIdentifier])
    {
        NSInteger  foudIndex = [[arrGlobalDevices valueForKey:@"identifier"] indexOfObject:strFoundIdentifier];
        if (foudIndex != NSNotFound)
        {
            if ([arrGlobalDevices count] > foudIndex)
            {
                NSString * strCurrentIdentifier = [NSString stringWithFormat:@"%@",classPeripheral.identifier];
                NSString * strName = [[arrGlobalDevices  objectAtIndex:foudIndex]valueForKey:@"name"];
                NSString * strAddress = [[arrGlobalDevices  objectAtIndex:foudIndex]valueForKey:@"bleAddress"];

                    [dataDict setObject:strCurrentIdentifier forKey:@"identifier"];
                    [dataDict setObject:classPeripheral forKey:@"peripheral"];
                    [dataDict setObject:strName forKey:@"device_name"];
                    [dataDict setObject:strAddress forKey:@"bleAddress"];
            }
        }
    }
    
    int timerSeconds = 0;
    if (isAvail == YES)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
                [NSTimer scheduledTimerWithTimeInterval:timerSeconds target:self selector:@selector(ShowDelayedPopup:) userInfo:dataDict repeats:NO];
        });
    }
    else
    {
        waitDict =  [[NSMutableDictionary alloc] init];
        waitDict = dataDict;
    }
}

-(void)ShowDelayedPopup:(NSTimer*)theTimer
{
    NSLog(@"-----------------> here we got the Popup delayed by 3 send--------->");
    NSString * strRuleId = [[theTimer userInfo] objectForKey:@"BreachRule_ID"];
    NSString * strBrechType = [[theTimer userInfo] objectForKey:@"Breach_Type"];
    NSString * strGeoID = [[theTimer userInfo] objectForKey:@"geofence_ID"];
    NSString * strBreachRuleValue = [[theTimer userInfo] objectForKey:@"BreachRuleValue"] ;
    NSString * strBreachLat = [[theTimer userInfo] objectForKey:@"Breach_Lat"] ;
    NSString * strBreachLon = [[theTimer userInfo] objectForKey:@"Breach_Long"] ;
    NSString * strBreachDateTime = [[theTimer userInfo] objectForKey:@"date_Time"] ;
    NSString * strBreachTimestamp = [[theTimer userInfo] objectForKey:@"timeStamp"] ;
    NSString * strBleAddress = [[[theTimer userInfo] objectForKey:@"bleAddress"] uppercaseString];
    NSString * strActualRuleValue = @"NA";
    NSString * strMsg = @"NA";
    NSString * strGeoType = @"NA";

    NSString * strQuery = [NSString stringWithFormat:@"select * from Geofence where geofence_ID = '%@'", strGeoID];
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arr];
    if ([arr count]>0)
    {
        strGeoType = [[arr objectAtIndex:0] valueForKey:@"type"];
    }

    currentAlertDict = [[theTimer userInfo] mutableCopy];
    NSString* strRuleName = [self getRuleNamefromRuleId:strRuleId];
    [currentAlertDict setObject:strRuleName forKey:@"Rule_Name"];
    [currentAlertDict setObject:strGeoType forKey:@"Geo_Type"];


    if ([strRuleId isEqual:@"07"])
    {
        if ([strBrechType isEqual:@"00"])
        {
            strMsg = [NSString stringWithFormat:@"SC2 Device : %@ went out of Geofence %@",strBleAddress,strGeoID];
            [self setupAlertView:strMsg withTitle:@"Boundry Cross Violation!" withDict:currentAlertDict];
        }
        else if ([strBrechType isEqual:@"01"])
        {
            strMsg = [NSString stringWithFormat:@"SC2 Device :%@ came in Geofence %@",strBleAddress,strGeoID];
            [self setupAlertView:strMsg  withTitle:@"Boundry Cross Violation!" withDict:currentAlertDict];
        }
    }
    else
    {
        NSString * strQuery1 = [NSString stringWithFormat:@"select rule_value from Rules_Table"];
        NSMutableArray * arr1 = [[NSMutableArray alloc] init];
        [[DataBaseManager dataBaseManager] execute:strQuery1 resultsArray:arr1];
        NSLog(@"kkkkkkkkppppppppp-->%@",arr1);

        NSString * strQuery = [NSString stringWithFormat:@"select rule_value from Rules_Table where geofence_ID = '%@' and rule_ID='%@'", strGeoID,strRuleId];
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:arr];
        if ([arr count]>0)
        {
            strActualRuleValue = [[arr objectAtIndex:0] valueForKey:@"rule_value"];
            [currentAlertDict setObject:strActualRuleValue forKey:@"OriginalRuleValue"];
        }
        if ([strRuleId isEqual:@"03"])
        {
            strMsg = [NSString stringWithFormat:@"SC2 Device : %@\nMinimum Dwell time Permitted : %@\nCurrent Time : %@", strBleAddress,[self getHoursfromString:strActualRuleValue],[self getHoursfromString:strBreachRuleValue]];

//            strMsg = [NSString stringWithFormat:@"SC2 device went out from Geofence %@ before Minimum dwell time (%@). Breach out time is %@.",strGeoID,[self getHoursfromString:strActualRuleValue], [self getHoursfromString:strBreachRuleValue]];
            [self setupAlertView:strMsg  withTitle:@"Breach Minimum Dwell Time" withDict:currentAlertDict];
        }
        else if ([strRuleId isEqual:@"04"])
        {
            strMsg = [NSString stringWithFormat:@"SC2 Device : %@\nMaximum Dwell time Permitted : %@\nCurrent Time : %@", strBleAddress,[self getHoursfromString:strActualRuleValue],[self getHoursfromString:strBreachRuleValue]];
            [self setupAlertView:strMsg  withTitle:@"Breach Maximum Dwell Time" withDict:currentAlertDict];
        }
        else if ([strRuleId isEqual:@"05"])
        {
            strMsg = [NSString stringWithFormat:@"SC2 Device : %@\nMinimum Speed limit: %@ km/h\nCurrent Speed : %@km/h", strBleAddress,strActualRuleValue,strBreachRuleValue];
            [self setupAlertView:strMsg  withTitle:@"Breach Minimum speed limit" withDict:currentAlertDict];
        }
        else if ([strRuleId isEqual:@"06"])
        {
            strMsg = [NSString stringWithFormat:@"SC2 Device : %@\nMaximum Speed limit: %@ km/h\nCurrent Speed : %@km/h", strBleAddress,strActualRuleValue,strBreachRuleValue];

//            strMsg = [NSString stringWithFormat:@"SC2 device breach maximum speed Rule of Geofence %@. Maximum speed is %@ km/h. Current speed is %@ km/h.",strGeoID, strActualRuleValue,strBreachRuleValue];
            [self setupAlertView:strMsg  withTitle:@"Breach Maximum speed limit" withDict:currentAlertDict];
        }
    }
    [currentAlertDict setObject:strMsg forKey:@"Message"];

    NSString * strNA = @"NA";
    NSString * strActionQuery =  [NSString stringWithFormat:@"insert into 'Geofence_alert_Table'('geofence_ID','Breach_Type','Breach_Lat','Breach_Long','BreachRule_ID','BreachRuleValue','Geo_name','Geo_Type','date_Time','timeStamp','Rule_Name','is_Read','OriginalRuleValue', 'bleAddress','Message') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strGeoID,strBrechType,strBreachLat,strBreachLon,strRuleId,strBreachRuleValue,strNA,strGeoType,strBreachDateTime,strBreachTimestamp,strRuleName,strNA,strActualRuleValue,strBleAddress,strMsg];
    [[DataBaseManager dataBaseManager] executeSw:strActionQuery];
}
-(NSString *)getHoursfromString:(NSString *)strVal
{
    NSString * strHr = [NSString stringWithFormat:@"%@ Min",strVal]; //Hrs
    int inthr = [strVal intValue];
    if (inthr > 1)
    {
        strHr = [NSString stringWithFormat:@"%@ Min",strVal];// Hrs
    }
    return strHr;
}
#pragma mark- Insert to database
-(void)InsertToDataBase
{
    if (globalDict.count > 0)
    {
        NSString * FLat = [NSString stringWithFormat:@"%f", [[globalDict valueForKey:@"Latitude"] floatValue]];
        NSString * FLong = [NSString stringWithFormat:@"%f", [[globalDict valueForKey:@"Longitude"] floatValue]];

        NSString * strName = [self checkforValidString:[globalDict valueForKey:@""]];
        NSString * strGeoFncID = [self checkforValidString:[globalDict valueForKey:@"GeofenceID"]];
        NSString * strGeoFncType = [self checkforValidString:[globalDict valueForKey:@"GeofenceType"]];
        NSString * strLat = [self checkforValidString:FLat]; //Latitude
        NSString * strLong = [self checkforValidString:FLong]; //Longitude
        NSString * strNoRules = [self checkforValidString:[globalDict valueForKey:@"NoRules"]];
        NSString * strIsActive = [self checkforValidString:[globalDict valueForKey:@"NA"]];
        NSString * strRadiusVertices = [self checkforValidString:[globalDict valueForKey:@"radiusOrvertices"]];
        NSString * strGSMtime = [self checkforValidString:[globalDict valueForKey:@"GSMtime"]];
        NSString * strIrridiumTime = [self checkforValidString:[globalDict valueForKey:@"IrridiumTime"]];

        NSString *query  = [NSString stringWithFormat:@"select * from Geofence where geofence_ID = '%@'",strGeoFncID];
        BOOL recordExist = [[DataBaseManager dataBaseManager] recordExistOrNot:query];
        
        if (recordExist)
        {
            NSString *  strUpdateQury =  [NSString stringWithFormat:@"update Geofence set name = \"%@\", geofence_ID = \"%@\", type = \"%@\", lat = \"%@\", long = \"%@\", number_of_rules = \"%@\", is_active = \"%@\", radiusOrvertices = \"%@\", gsm_time = '%@', irridium_time = '%@' where id =\"%@\"",strName,strGeoFncID,strGeoFncType,strLat,strLong,strNoRules,strIsActive,strRadiusVertices,strGSMtime,strIrridiumTime,[globalDict valueForKey:@"GeofenceID"]];
            [[DataBaseManager dataBaseManager] execute:strUpdateQury];
        }
        else
        {
            NSString * strGeofenceQuery = [NSString stringWithFormat:@"insert into 'Geofence'('name','geofence_ID','type','lat','long','number_of_rules','is_active','radiusOrvertices','gsm_time','irridium_time') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strName,strGeoFncID,strGeoFncType,strLat,strLong,strNoRules,strIsActive,strRadiusVertices,strGSMtime,strIrridiumTime];
            [[DataBaseManager dataBaseManager] execute:strGeofenceQuery];
        }

        NSString * strDeleteRules = [NSString stringWithFormat:@"delete from Rules_Table where geofence_ID = '%@'",strGeoFncID];
        [[DataBaseManager dataBaseManager] executeSw:strDeleteRules];
        for (int i = 0; i < [arrRules count]; i++)
        {
            NSString * strRuleID = [self checkforValidString:[[arrRules objectAtIndex:i] valueForKey:@"RuleID"]];
            NSString * strValue  = [self checkforValidString:[[arrRules objectAtIndex:i] valueForKey:@"Value"]];
            NSString * strRuleNO = [self checkforValidString:[[arrRules objectAtIndex:i] valueForKey:@"NoAction"]];

            NSString * strRulesQuery =    [NSString stringWithFormat:@"insert into 'Rules_Table'('name','geofence_ID','rule_ID','rule_value','rule_number') values(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",strName,strGeoFncID,strRuleID,strValue,strRuleNO];
             [[DataBaseManager dataBaseManager] executeSw:strRulesQuery];
        }
            
        /*for (int i=0 ; i<[arrActons count]; i++)
        {
            NSString * strActionID = [[arrActons objectAtIndex:i] valueForKey:@"ActionID"];
            NSString * stractionVlaue = [[arrActons objectAtIndex:i] valueForKey:@"ActionValue"];
            NSString * strRuleId = [[arrActons objectAtIndex:i] valueForKey:@"RuleId"];

            NSString * strGeoFncID = [self checkforValidString:[globalDict valueForKey:@"GeofenceID"]];
            
            NSString * strActionQuery =  [NSString stringWithFormat:@"insert into 'Action_Table'('geofence_ID','action_ID','action_value','RuleId') values(\"%@\",\"%@\",\"%@\",\"%@\")",strGeoFncID,strActionID,stractionVlaue,strRuleId];
            [[DataBaseManager dataBaseManager] execute:strActionQuery];
        }*/
        
        if ([strGeoFncType isEqualToString:@"01"])
        {
            NSString * strDeletePolygon = [NSString stringWithFormat:@"delete from Polygon_Lat_Long where geofence_ID = '%@'",strGeoFncID];
            [[DataBaseManager dataBaseManager] executeSw:strDeletePolygon];

            for (int i=0 ; i<[arrPolygon count]; i++)
            {
                NSString * strLat = [[arrPolygon objectAtIndex:i] valueForKey:@"lat"];
                NSString * strLon = [[arrPolygon objectAtIndex:i] valueForKey:@"lon"];
                NSString * strActionQuery =  [NSString stringWithFormat:@"insert into 'Polygon_Lat_Long'('geofence_ID','lat','long') values(\"%@\",\"%@\",\"%@\")",strGeoFncID,strLat,strLon];
                [[DataBaseManager dataBaseManager] execute:strActionQuery];
            }
        }
        if ([arrGeofence count] == 0)
        {
            arrGeofence = [[NSMutableArray alloc]init];
            NSString * str = [NSString stringWithFormat:@"Select * from Geofence"];
            [[DataBaseManager dataBaseManager] execute:str resultsArray:arrGeofence];
        }
        globalDict = [[NSMutableDictionary alloc] init];
        arrActons = [[NSMutableArray alloc] init];
        arrRules = [[NSMutableArray alloc] init];
        arrPolygon = [[NSMutableArray alloc] init];

    }
}
@end
