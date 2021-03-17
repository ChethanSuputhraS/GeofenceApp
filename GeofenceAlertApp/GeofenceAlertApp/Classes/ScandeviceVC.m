//
//  ScandeviceVC.m
//  GeofenceAlertApp
//
//  Created by Ashwin on 7/16/20.
//  Copyright © 2020 srivatsa s pobbathi. All rights reserved.
//

#import "ScandeviceVC.h"
#import "ScanDeviceCell.h"
#import <UserNotifications/UserNotifications.h>
#import "HomeVC.h"
#import "HomeCell.h"
#import "BLEManager.h"
#import "BLEService.h"


@interface ScandeviceVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UILabel *  lblNoDevice ;
    CBCentralManager*centralManager;
    NSTimer * connectionTimer;
    CBPeripheral * classPeripheral;
}
@end

@implementation ScandeviceVC

- (void)viewDidLoad
{
  
    
    [self setNavigationViewFrames];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AuthenticationCompleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AuthenticationCompleted:) name:@"AuthenticationCompleted" object:nil];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
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
    if (@available(iOS 10.0, *)) {
        if (centralManager.state == CBCentralManagerStatePoweredOn || centralManager.state == CBManagerStateUnknown)
        {
        }
        else
        {
            [self GlobalBLuetoothCheck];
        }
    }
    else
    {
        if (centralManager.state == CBCentralManagerStatePoweredOff)
        {
            [self GlobalBLuetoothCheck];
            [[[BLEManager sharedManager] nonConnectArr] removeAllObjects];
            [[BLEManager sharedManager] rescan];
        }
    }
    [self InitialBLE];

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
    [lblTitle setText:@"Scan Device"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * imgBack = [[UIImageView alloc]initWithFrame:CGRectMake(10,globalStatusHeight+11, 14, 22)];
    imgBack.image = [UIImage imageNamed:@"back_icon.png"];
    imgBack.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgBack];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, 0, 80, yy+globalStatusHeight)];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnBack];
    
    tblDevice = [[UITableView alloc] initWithFrame:CGRectMake(0, yy+globalStatusHeight, DEVICE_WIDTH, DEVICE_HEIGHT-yy)];
    tblDevice.delegate = self;
    tblDevice.dataSource= self;
    tblDevice.backgroundColor = UIColor.clearColor;
    tblDevice.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:tblDevice];
    
    topPullToRefreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:tblDevice withClient:self];
    [topPullToRefreshManager setPullToRefreshViewVisible:YES];
    [topPullToRefreshManager tableViewReloadFinishedAnimated:YES];

    
    
        lblNoDevice = [[UILabel alloc]initWithFrame:CGRectMake(30, (DEVICE_HEIGHT/2)-90, (DEVICE_WIDTH)-60, 100)];
        lblNoDevice.backgroundColor = UIColor.clearColor;
        [lblNoDevice setTextAlignment:NSTextAlignmentCenter];
        [lblNoDevice setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
        [lblNoDevice setTextColor:[UIColor whiteColor]];
    //    lblNoDevice.layer.masksToBounds = true;
    //    lblNoDevice.layer.cornerRadius = 15;
        lblNoDevice.text = @"No Devices Found.";
        [self.view addSubview:lblNoDevice];
    
}
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
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
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
{

    UIView * headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-146, 30)];
    headerView.backgroundColor = [UIColor blackColor];
        
    UILabel *lblHeader=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 30)];
    lblHeader.backgroundColor = UIColor.lightGrayColor;
    lblHeader.alpha = 0.7;
    lblHeader.text= @"  Tap on connect Button to connect";
    lblHeader.textColor = UIColor.whiteColor;
    lblHeader.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:lblHeader];
        return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 30;
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
        cell.lblAddress.text = [[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"address"];
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
        cell.lblAddress.text = [[arrayDevices  objectAtIndex:indexPath.row]valueForKey:@"address"];
    }
    
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [connectionTimer invalidate];
    connectionTimer = nil;
    connectionTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(ConnectionTimeOutMethod) userInfo:nil repeats:NO];
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
//            strBleAddress = [[arrayDevices objectAtIndex:indexPath.row] valueForKey:@"address"];
            isConnectedtoAdd = YES;
            classPeripheral = p;
            [APP_DELEGATE startHudProcess:@"Connecting..."];
            [[BLEManager sharedManager] connectDevice:p];
        }
    }
}
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

#pragma mark - BLE Methods
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
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       // UIView usage
                       if ( [[[BLEManager sharedManager] foundDevices] count] >0)
                       {
                           self->tblDevice.hidden = false;
                           self->lblNoDevice.hidden = true;
//                           NSLog(@"found array is %@",[[BLEManager sharedManager] foundDevices]); // device found
                       }
                       else
                       {
                           self->tblDevice.hidden = true;
                           self->lblNoDevice.hidden = false;
                       }
                       [self->tblDevice reloadData];
                   });
}
-(void)DeviceDidConnectNotification:(NSNotification*)notification//Connect periperal
{
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                        [APP_DELEGATE endHudProcess];
                           [self->tblDevice reloadData];
                       });
}
-(void)DeviceDidDisConnectNotification:(NSNotification*)notification//Disconnect periperal
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
        
        [[[BLEManager sharedManager] foundDevices] removeAllObjects];
        [[BLEManager sharedManager] rescan];
        [self->tblDevice reloadData];

        [APP_DELEGATE endHudProcess];
                   });
}
-(void)GlobalBLuetoothCheck
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Geofence Alert" message:@"Please enable Bluetooth Connection. Tap on enable Bluetooth icon by swiping Up." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:true completion:nil];
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
    [[[BLEManager sharedManager] foundDevices] removeAllObjects];
    [[BLEManager sharedManager] rescan];
    [tblDevice reloadData];
    
    [topPullToRefreshManager tableViewReloadFinishedAnimated:NO];
}

-(void)AuthenticationCompleted:(NSNotification *)notify
{
    globalPeripheral = classPeripheral;
    [globalHomeVC WritetoDevicetogetGeofenceDetail:@"NA"];
//    [self.navigationController popViewControllerAnimated:YES];
}
@end
