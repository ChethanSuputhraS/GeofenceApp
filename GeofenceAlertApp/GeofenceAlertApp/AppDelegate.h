//
//  AppDelegate.h
//  GeofenceAlertApp
//
//  Created by srivatsa s pobbathi on 06/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "MBProgressHUD.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "HomeVC.h"
#import "HistoryVC.h"

HomeVC * globalHomeVC;
HistoryVC * globalHistoryVC;

double globalLatitude, globalLongitude;
double deviceLatitude, deviceLongitude;
int globalBadgeCount;
int textSize,updatedRSSI;
int globalStatusHeight;
BOOL isConnectedtoAdd;
BOOL isCheckforDashScann;
NSMutableArray * arrGlobalDevices;
CLLocationManager * locationManager;
CBPeripheral * globalPeripheral;
NSString * strCurrentScreen;
NSString * globalSequence;


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MBProgressHUD *HUD;
    UITabBarController * mainTabBarController;
    
    UINavigationController *firstNavigation;
    UINavigationController *secondNavigation;
    UINavigationController *thirdNavigation;
}
@property (strong, nonatomic) UIWindow *window;

#pragma mark - Helper Classes
-(NSString *)checkforValidString:(NSString *)strRequest;
-(void)startHudProcess:(NSString *)text;
-(void)endHudProcess;
-(void)updateBadgeCount;
-(void)hideTabBar:(UITabBarController *) tabbarcontroller;
-(void)showTabBar:(UITabBarController *) tabbarcontroller;
-(NSString *)getbackgroundImage;

@end


//AIzaSyCl_QnzYBK6eJW1CDQGaArWmQwdqg2XvgA

