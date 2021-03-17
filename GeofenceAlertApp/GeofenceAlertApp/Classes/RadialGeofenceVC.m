//
//  RadialGeofenceVC.m
//  GeofenceAlertApp
//
//  Created by Kalpesh Panchasara on 26/07/20.
//  Copyright © 2020 srivatsa s pobbathi. All rights reserved.
//

#import "RadialGeofenceVC.h"
#import "HomeVC.h"
#import <math.h>
#import "CustomAnnotation.h"
#import "CustomAnnotationView.h"
#define span1 10000

@interface RadialGeofenceVC ()<MKMapViewDelegate>
{
    MKMapView *_mapView;
    MKCircle *_radialCircle;
    CLLocation *_location;
    double radiusValue;
    MKPointAnnotation * annotation1;
    double geofenceLat, geofenceLong;
    double breachLat, breachLong;
    NSString * strScreenMode;

    CustomAnnotation * annotationPin;
    CustomAnnotationView* custannotationView;
}
@end

@implementation RadialGeofenceVC
@synthesize dictGeofenceInfo,isfromEdit;

- (void)viewDidLoad
{
    strScreenMode = @"Light";
    if (@available(iOS 12.0, *))
    {
            switch (UIScreen.mainScreen.traitCollection.userInterfaceStyle) {
                case UIUserInterfaceStyleDark:
                    // put your dark mode code here
                    strScreenMode = @"Dark";
                    break;
                case UIUserInterfaceStyleLight:
                case UIUserInterfaceStyleUnspecified:
                    break;
                default:
                    break;
            }
    }
    
    self.view.backgroundColor = UIColor.clearColor;
    
    breachLat = globalLatitude;
    breachLong = globalLongitude;
    
    geofenceLat = globalLatitude;
    geofenceLong = globalLongitude;

    if (![[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"Breach_Lat"]] isEqualToString:@"NA"])
    {
        breachLat = [[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"Breach_Lat"]] doubleValue];
        breachLong = [[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"Breach_Long"]] doubleValue];
    }

    radiusValue = 20;

    NSString * strQuery = [NSString stringWithFormat:@"select * from Geofence where geofence_ID = '%@'",[dictGeofenceInfo valueForKey:@"Geofence_ID"]];//kalpesh Change Geofence_ID to geofence_ID
    NSMutableArray * dataArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:dataArr];
    if ([dataArr count]>0)
    {
        if (![[APP_DELEGATE checkforValidString:[[dataArr objectAtIndex:0] valueForKey:@"lat"]] isEqualToString:@"NA"])
        {
            geofenceLat = [[[dataArr objectAtIndex:0] valueForKey:@"lat"] doubleValue];
            geofenceLong = [[[dataArr objectAtIndex:0] valueForKey:@"long"] doubleValue];
        }
        if (![[APP_DELEGATE checkforValidString:[[dataArr objectAtIndex:0] valueForKey:@"radiusOrvertices"]] isEqualToString:@"NA"])
        {
            radiusValue = [[[dataArr objectAtIndex:0] valueForKey:@"radiusOrvertices"] doubleValue];
        }
    }
    [self setUpNavigatonView];
    [self setUpMapView];
    
    _location = [[CLLocation alloc] initWithLatitude:geofenceLat longitude:geofenceLong];
    [self setupLocation:_location];

//    [dictGeofenceInfo setValue:[dictGeofenceInfo valueForKey:@"Violated_ID"] forKey:@"BreachRule_ID"];//Commen this line as Violated_ID is BreachRule_ID....
//    [dictGeofenceInfo setValue:[dictGeofenceInfo valueForKey:@"Value"] forKey:@"BreachRuleValue"];//Commen this line as Violated_ID is BreachRule_ID....

//    Violated_ID
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidAppear:(BOOL)animated
{
}
-(void)setUpNavigatonView
{
    int  yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }

    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy + globalStatusHeight)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
  
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, globalStatusHeight, DEVICE_WIDTH-100, yy-globalStatusHeight)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Geofence Location"];
//    lblTitle.text = [NSString stringWithFormat:@"Radial ID: %@",[dictGeofenceInfo valueForKey:@"bleAddress"]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];

    UIImageView * imgBack = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+11, 14, 22)];
    imgBack.image = [UIImage imageNamed:@"back_icon.png"];
    imgBack.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgBack];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, 0, 80, yy)];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnBack];

    if (IS_IPHONE_X)
    {
        lblTitle.frame = CGRectMake(50, 45, DEVICE_WIDTH-100, 15);
        imgBack.frame = CGRectMake(10,40+11, 14, 22);
    }
}
-(void)setUpMapView
{
    int yy = 64;
    if (IS_IPHONE_X) {
        yy = 84;
    }
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy)];
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
}


- (void)setupLocation:(CLLocation *)currentLocation
{
//    radiusValue = [dictGeofenceInfo valueForKey:@"bleAddress"];
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeOverlay:_radialCircle];
    [_mapView zoomToLocation:currentLocation withMarginInMeters:radiusValue animated:YES];
    _radialCircle = [MKCircle circleWithCenterCoordinate:currentLocation.coordinate radius:radiusValue];
    [_mapView addOverlay:_radialCircle];
    
    CLLocation * breachLocation = [[CLLocation alloc] initWithLatitude:breachLat longitude:breachLong];

//
    [_mapView removeAnnotations:_mapView.annotations];
    annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = breachLocation.coordinate;
    annotation1.title = @"SC2 device location";
    [_mapView addAnnotation:annotation1];

    if (![[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"bleAddress"]] isEqualToString:@"NA"])
    {
        annotation1.title = [NSString stringWithFormat:@"%@'s location",[dictGeofenceInfo valueForKey:@"bleAddress"]];
    }
}
#pragma mark - MapView Delegate
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if(newState == MKAnnotationViewDragStateStarting)
    {
    }
    else if (newState == MKAnnotationViewDragStateEnding)
    {
        [_mapView removeOverlay:_radialCircle];

//        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
//        self->changedLat = droppedAt.latitude;
//        self->changedLong = droppedAt.longitude;

//        if (isfromEdit)
//        {
//            [self DetectWhetherPointinGefoencewith:self->changedLat withLong:self->changedLong];
//        }
//        else
        {
//            CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
//            _location = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
//            _radialCircle = [MKCircle circleWithCenterCoordinate:_location.coordinate radius:radiusValue];
//            [_mapView addOverlay:_radialCircle];
//            [self changeRadius:radiusValue];
//
//            [_mapView removeAnnotations:_mapView.annotations];
//            annotation1 = [[MKPointAnnotation alloc] init];
//            annotation1.coordinate = annotationView.annotation.coordinate;
//            annotation1.title = @"My current Location";
////            [mapView addAnnotation:annotation1];
//            if (![[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"bleAddress"]] isEqualToString:@"NA"])
//            {
//                annotation1.title = [NSString stringWithFormat:@"%@'s location",[dictGeofenceInfo valueForKey:@"bleAddress"]];
//            }

            
//            NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    UIColor * overlayColor = [UIColor blackColor];
    if ([strScreenMode isEqualToString:@"Dark"])
    {
        overlayColor = [UIColor blueColor];
    }
    MKCircleRenderer * renderer = [[MKCircleRenderer alloc] initWithCircle:_radialCircle];
    renderer.strokeColor = overlayColor;
    renderer.fillColor = overlayColor;
    renderer.alpha = .4f;
    renderer.lineWidth = 1;
    return renderer;
}
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation coordinate].latitude == geofenceLat &&  [annotation coordinate].longitude == geofenceLong)
       {
           return nil;
       }
        static NSString * const identifier = @"CustomAnnotation";
        custannotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        if (custannotationView)
        {
            custannotationView.annotation = annotation;
        }
        else
        {
            custannotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
   
        custannotationView.canShowCallout = NO;
        custannotationView.image = [UIImage imageNamed:@"map_pin.png"];
    if ([strScreenMode isEqualToString:@"Dark"])
    {
        custannotationView.image = [UIImage imageNamed:@"MapPinWhite.png"];
    }
    if ([[dictGeofenceInfo valueForKey:@"BreachRule_ID"] isEqualToString:@"07"])
    {
        custannotationView.subtitle1 = [NSString stringWithFormat:@"SC2 Device: %@",[[dictGeofenceInfo valueForKey:@"bleAddress"] uppercaseString]];
        custannotationView.subtitle2 = @" ";
        custannotationView.subtitle3 = @"SC2 device Went out of Geofence.";
        custannotationView.subtitle4 =@" ";
        if ([[dictGeofenceInfo valueForKey:@"Breach_Type"] isEqualToString:@"01"])
        {
            custannotationView.subtitle3 = @"SC2 device came in Geofence.";
        }
    }
    else
    {
        NSString * strTitle, * strMessage, * strCurrentVal, * strOriginVal;
        NSString * strAddres = [NSString stringWithFormat:@"SC2 Device: %@",[[dictGeofenceInfo valueForKey:@"bleAddress"] uppercaseString]];
        strCurrentVal = [dictGeofenceInfo valueForKey:@"BreachRuleValue"];
        strOriginVal = [dictGeofenceInfo valueForKey:@"OriginalRuleValue"];

        if ([[dictGeofenceInfo valueForKey:@"BreachRule_ID"] isEqualToString:@"03"])
        {
            strTitle = [NSString stringWithFormat:@"Breach Minimum Dwell Time : %@",[self getHoursfromString:strOriginVal]];
            strMessage = [NSString stringWithFormat:@"Current time is : %@",[self getHoursfromString:strCurrentVal]];
        }
        else if ([[dictGeofenceInfo valueForKey:@"BreachRule_ID"] isEqualToString:@"04"])
        {
            strTitle = [NSString stringWithFormat:@"Breach Maximum Dwell Time : %@",[self getHoursfromString:strOriginVal]];
            strMessage = [NSString stringWithFormat:@"Current time is : %@",[self getHoursfromString:strCurrentVal]];
        }
        else if ([[dictGeofenceInfo valueForKey:@"BreachRule_ID"] isEqualToString:@"05"])
        {
            strTitle = [NSString stringWithFormat:@"Breach Minimum speed limit : %@ km/h",strOriginVal];
            strMessage = [NSString stringWithFormat:@"Current speed is : %@ km/h",strCurrentVal];
        }
        else if ([[dictGeofenceInfo valueForKey:@"BreachRule_ID"] isEqualToString:@"06"])
        {
            strTitle = [NSString stringWithFormat:@"Breach Maximum speed limit : %@ km/h",strOriginVal];
            strMessage = [NSString stringWithFormat:@"Current speed is : %@ km/h",strCurrentVal];
        }
        custannotationView.subtitle1 = strAddres;
        custannotationView.subtitle2 = @" ";
        custannotationView.subtitle3 = strTitle;
        custannotationView.subtitle4 =strMessage;
    }
    return custannotationView;
}
-(NSString *)getHoursfromString:(NSString *)strVal
{
    NSString * strHr = [NSString stringWithFormat:@"%@ Hr",strVal];
    int inthr = [strVal intValue];
    if (inthr > 1)
    {
        strHr = [NSString stringWithFormat:@"%@ Hrs",strVal];
    }
    return strHr;
}
-(void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    if([views count]>0)
    {
        MKAnnotationView *annotationView = [views objectAtIndex:0];
        if (annotationView)
        {
            id <MKAnnotation> mp = [annotationView annotation];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance
            ([mp coordinate], 100, 100);
            if (region.center.latitude > -89 && region.center.latitude < 89 && region.center.longitude > -179 && region.center.longitude < 179 )
            {
                [mv setRegion:region animated:YES];
                [mv selectAnnotation:mp animated:YES];
            }
        }
    }
}

#pragma mark - All Button Click Events
-(void)btnBackClick
{
    if (self.isfromHistory == YES)
    {
        [self.navigationController popViewControllerAnimated:true];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)DetectWhetherPointinGefoencewith:(double)latitude withLong:(double)longitude
{
    double R = [[dictGeofenceInfo valueForKey:@"radius"] doubleValue]; // Radius of the earth in km

    double lat2 = [[dictGeofenceInfo valueForKey:@"lat"] doubleValue];
    double lon2 = [[dictGeofenceInfo valueForKey:@"long"] doubleValue];
    double lat1 = latitude;
    double lon1 = longitude;
    
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:lat2 longitude:lon2];
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    NSLog(@"KILOMETER1=%f",(distance/1000) * R);
}
@end
