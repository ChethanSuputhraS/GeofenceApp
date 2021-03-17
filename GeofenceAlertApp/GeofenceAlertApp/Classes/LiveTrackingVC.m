//
//  LiveTrackingVC.m
//  GeofenceAlertApp
//
//  Created by srivatsa s pobbathi on 12/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "LiveTrackingVC.h"

@interface LiveTrackingVC ()

@end

@implementation LiveTrackingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavigationViewFrames];
    [self setContentViewFrames];
    // Do any additional setup after loading the view.
}
#pragma mark - Set Frames
-(void)setNavigationViewFrames
{
    int  yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    UIImageView * imgLogo = [[UIImageView alloc] init];
    imgLogo.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    imgLogo.image = [UIImage imageNamed:@"Splash_bg.png"];
    imgLogo.userInteractionEnabled = YES;
    [self.view addSubview:imgLogo];
    
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Live Tracking"];
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
        lblTitle.frame = CGRectMake(50, 40, DEVICE_WIDTH-100, 44);
        imgBack.frame = CGRectMake(10,40+11, 14, 22);
    }
}
-(void)setContentViewFrames
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }
    searchBar = [[UISearchBar alloc]init];
    searchBar.delegate = self;
    searchBar.frame = CGRectMake(0, yy, self.view.frame.size.width, 50);
    [self.view addSubview:searchBar];
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, yy+50, DEVICE_WIDTH,DEVICE_HEIGHT-yy-50)];
    [mapView setDelegate:self];
    mapView.showsUserLocation = false;
    mapView.mapType = MKMapTypeStandard;
    [self.view addSubview:mapView];
    
   
    
    BOOL isDeviceLocationAvail = NO;
    
    double latestLat =  globalLatitude;
    double latestLong = globalLongitude;
    if (globalPeripheral.state == CBPeripheralStateConnected)
    {
        if (deviceLatitude != 0)
        {
            isDeviceLocationAvail = YES;
            latestLat = deviceLatitude;
            latestLong = deviceLongitude;
        }
    }
    CLLocationCoordinate2D sourceCoords = CLLocationCoordinate2DMake(latestLat, latestLong);
    
    MKPlacemark *placemark  = [[MKPlacemark alloc] initWithCoordinate:sourceCoords addressDictionary:nil];
    [mapView removeAnnotation:annotation1];
    annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = sourceCoords;
    annotation1.title = @"Device Location";
    [mapView addAnnotation:annotation1];
    [mapView addAnnotation:placemark];
    
    if (isDeviceLocationAvail)
    {
       /* CLLocationCoordinate2D deviceCords = CLLocationCoordinate2DMake(9.9252, 78.1198);
        MKPlacemark *placemark2  = [[MKPlacemark alloc] initWithCoordinate:deviceCords addressDictionary:nil];
        annotation2 = [[MKPointAnnotation alloc] init];
        annotation2.coordinate = deviceCords;
        annotation2.title = @"Device Location";
        [mapView addAnnotation:annotation2];
        [mapView addAnnotation:placemark2];*/

    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    NSString *address = [NSString stringWithFormat:@"%@",theSearchBar.text];
    CLGeocoder * geocoder = [[CLGeocoder alloc]init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(!error)
         {
             [self->searchBar resignFirstResponder];
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSLog(@"%f",placemark.location.coordinate.latitude);
             NSLog(@"%f",placemark.location.coordinate.longitude);
             NSLog(@"%@",[NSString stringWithFormat:@"%@",[placemark description]]);
             
             CLLocationCoordinate2D destCoords = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);
             [self->mapView removeAnnotation:self->annotation1];
             self->annotation1.coordinate = destCoords;
             self->annotation1.title = @"My Location";
             [self->mapView addAnnotation:self->annotation1];
         }
         else
         {
             URBAlertView *alertView = [[URBAlertView alloc] initWithTitle:ALERT_TITLE message:@"Searched Location is not available" cancelButtonTitle:OK_BTN otherButtonTitles: nil, nil];
             [alertView setMessageFont:[UIFont fontWithName:CGRegular size:14]];
             [alertView setHandlerBlock:^(NSInteger buttonIndex, URBAlertView *alertView) {
                 [alertView hideWithCompletionBlock:^{}];
             }];
             [alertView showWithAnimation:URBAlertAnimationTopToBottom];
             if (IS_IPHONE_X){[alertView showWithAnimation:URBAlertAnimationDefault];}
             
             NSLog(@"Error,not able to fetch",[error localizedDescription]);
         }
     }
     ];}
#pragma mark - Map View Delegates
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
//    MKAnnotationView *aV;
//    for (aV in views)
//    {
//        // Don't pin drop if annotation is user location
//        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
//            continue;
//        }
//        // Check if current annotation is inside visible map rect, else go to next one
//        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
//        if (!MKMapRectContainsPoint(mapView.visibleMapRect, point)) {
//            continue;
//        }
//        CGRect endFrame = aV.frame;
//        // Move annotation out of view
//        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - self.view.frame.size.height, aV.frame.size.width, aV.frame.size.height);
//        // Animate drop
//        [UIView animateWithDuration:0.5 delay:0.04*[views indexOfObject:aV] options:UIViewAnimationCurveLinear animations:^{
//            aV.frame = endFrame;
//            // Animate squash
//        }completion:^(BOOL finished){
//            if (finished) {
//                [UIView animateWithDuration:0.05 animations:^{
//                    aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
//
//                }completion:^(BOOL finished){
//                    [UIView animateWithDuration:0.1 animations:^{
//                        aV.transform = CGAffineTransformIdentity;
//                    }];
//                }];
//            }
//        }];
        // to zoom as soon as your mapview is loaded
        MKAnnotationView *annotationView = [views objectAtIndex:0];
        id <MKAnnotation> mp = [annotationView annotation];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance
        ([mp coordinate], 1000000, 1000000);
        [mapView setRegion:region animated:YES];
        [mapView selectAnnotation:mp animated:YES];
    
}
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: @"pin"];
    if (pin == nil)
    {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"pin"];
    }
    else
    {
        pin.annotation = annotation;
    }
    if ([annotation.title isEqualToString:@"Device Location"])
    {
        [pin setPinColor:MKPinAnnotationColorGreen ] ;
        
    }
    else
    {
        [pin setPinColor:MKPinAnnotationColorRed ] ;
    }
    pin.animatesDrop = YES;
    pin.draggable = YES;
    pin.canShowCallout = true;
    return pin;
}

#pragma mark - All Button Clicks
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
