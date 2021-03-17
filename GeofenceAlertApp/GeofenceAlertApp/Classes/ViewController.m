//
//  ViewController.m
//  GeofenceAlertApp
//
//  Created by srivatsa s pobbathi on 06/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "ViewController.h"
#import "HomeVC.h"
#import <math.h>
#import "CustomAnnotation.h"
#import "CustomAnnotationView.h"


#define span1 10000

@interface ViewController ()<MKMapViewDelegate>
{
    MKMapView *_mapView;
    MKCircle *_radialCircle;
    CLLocation *_location;
    double radiusValue;
    MKPointAnnotation * annotation1;
    double classlat, classLong;
    
    CustomAnnotation * annotationPin;
    CustomAnnotationView* custannotationView;

}
@end

@implementation ViewController
@synthesize dictGeofenceInfo,isfromEdit;
- (void)viewDidLoad
{
    self.view.backgroundColor = UIColor.clearColor;
    [super viewDidLoad];
    
    [self setUpNavigatonView];
    [self setUpMapView];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewDidAppear:(BOOL)animated
{
    classlat = globalLatitude;
    classLong = globalLongitude;
    if (isfromEdit)
    {
        classlat = [[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"lat"]] doubleValue];
        classLong = [[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"long"]] doubleValue];
    }
    self->changedLat = classlat;
    self->changedLong = classLong;

    _location = [[CLLocation alloc] initWithLatitude:classlat longitude:classLong];
    [self setupLocation:_location];
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
    [lblTitle setText:@"GeoFence id pass here"];
    lblTitle.text = [NSString stringWithFormat:@"Radial ID: %@",[dictGeofenceInfo valueForKey:@"geofence_ID"]];
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
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeOverlay:_radialCircle];
    [_mapView zoomToLocation:currentLocation withMarginInMeters:radiusValue animated:YES];
    _radialCircle = [MKCircle circleWithCenterCoordinate:currentLocation.coordinate radius:radiusValue];
    [_mapView addOverlay:_radialCircle];
    
    [_mapView removeAnnotations:_mapView.annotations];
    annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = currentLocation.coordinate;
    annotation1.title = @"My current Location";
    [_mapView addAnnotation:annotation1];
    
    CLLocationCoordinate2D location=CLLocationCoordinate2DMake(classlat, classLong);
    MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(location,radiusValue*2 ,radiusValue*2);
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:region];
    [_mapView setRegion:adjustedRegion animated:YES];

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

        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        self->changedLat = droppedAt.latitude;
        self->changedLong = droppedAt.longitude;

//        if (isfromEdit)
//        {
//            [self DetectWhetherPointinGefoencewith:self->changedLat withLong:self->changedLong];
//        }
//        else
        {
            CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
            _location = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
            _radialCircle = [MKCircle circleWithCenterCoordinate:_location.coordinate radius:radiusValue];
            [_mapView addOverlay:_radialCircle];
            [self changeRadius:radiusValue];
            
            [_mapView removeAnnotations:_mapView.annotations];
            annotation1 = [[MKPointAnnotation alloc] init];
            annotation1.coordinate = annotationView.annotation.coordinate;
            annotation1.title = @"My current Location";
            [mapView addAnnotation:annotation1];
            
            NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKCircleRenderer * renderer = [[MKCircleRenderer alloc] initWithCircle:_radialCircle];
    renderer.strokeColor = [UIColor blackColor];
    renderer.fillColor = [UIColor blueColor];
    renderer.alpha = .4f;
    renderer.lineWidth = 1;
    return renderer;
}
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
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
        custannotationView.subtitle1 = [NSString stringWithFormat:@"ID: %@",[dictGeofenceInfo valueForKey:@"geofence_ID"]];
        custannotationView.subtitle2 = [NSString stringWithFormat:@"Type: %@",[dictGeofenceInfo valueForKey:@"type"]];
    custannotationView.subtitle3 = @"State of voilence";
//    [NSString stringWithFormat:@"ID: %@",[dictGeofenceInfo valueForKey:@"geofence_ID"]];
    custannotationView.subtitle4 =@"Note here";
//    [NSString stringWithFormat:@"ID: %@",[dictGeofenceInfo valueForKey:@"geofence_ID"]];

        return custannotationView;

    return custannotationView;
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
            ([mp coordinate], 1000, 1000);
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
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnSaveClick
{
    NSString * strName = [APP_DELEGATE checkforValidString:[dictGeofenceInfo objectForKey:@"name"]];
    NSString * strRadius = [APP_DELEGATE checkforValidString:[dictGeofenceInfo objectForKey:@"radius"]];
    NSString * strLats = [NSString stringWithFormat:@"%f",self->changedLat];
    NSString * strLongs = [NSString stringWithFormat:@"%f",self->changedLong];
    NSString * strType = [APP_DELEGATE checkforValidString:[dictGeofenceInfo objectForKey:@"type"]];

    if (isfromEdit)
    {
        NSString * strUpdate = [NSString stringWithFormat:@"update Geofence set name ='%@', radius = '%@', lat ='%@', long='%@',type = '%@' where id ='%@'",strName,strRadius,strLats,strLongs,strType,[dictGeofenceInfo objectForKey:@"id"]];
        [[DataBaseManager dataBaseManager] execute:strUpdate];
    }
    else
    {
        NSString * requestStr =[NSString stringWithFormat:@"insert into 'Geofence'('name','radius','type','is_active','lat','long')values(\"%@\",\"%@\",\"%@\",'1',\"%@\",\"%@\")",[dictGeofenceInfo objectForKey:@"name"],[dictGeofenceInfo objectForKey:@"radius"],[dictGeofenceInfo objectForKey:@"type"],strLats,strLongs];
        [[DataBaseManager dataBaseManager]execute:requestStr];
    }
    
//    double lats = self->changedLat;
//    double longs = self->changedLong;
//    double radiuss = [[dictGeofenceInfo objectForKey:@"radius"] doubleValue];

//    CLLocationCoordinate2D centreLoc = {lats, longs};
//    CLLocationDistance regionRadius = radiuss*1000;
//    
//    CLCircularRegion * grRegion = [[CLCircularRegion alloc] initWithCenter:centreLoc radius:regionRadius identifier:strName];
//    [locationManager startMonitoringForRegion:grRegion];


    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}
#pragma mark - Geofence Actions
- (IBAction)changeRadius:(float)slider
{
    NSOperationQueue *currentQueue = [NSOperationQueue new];
    __block MKCircle *radialCircle = nil;
    
    NSOperation *createOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            radialCircle = [MKCircle circleWithCenterCoordinate:self->_location.coordinate radius:slider];
            [self->_mapView addOverlay:radialCircle];
        });
    }];
    
    NSOperation *removeOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_mapView removeOverlay:self->_radialCircle];
            @synchronized(self){
                self->_radialCircle = radialCircle;
            }
        });
    }];
    
    [removeOperation addDependency:createOperation];
    [currentQueue addOperations:@[createOperation, removeOperation] waitUntilFinished:YES];
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
