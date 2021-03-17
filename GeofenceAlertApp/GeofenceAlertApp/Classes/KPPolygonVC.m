//
//  KPPolygonVC.m
//  GeofenceAlertApp
//
//  Created by stuart watts on 17/06/2019.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "KPPolygonVC.h"

@interface KPPolygonVC ()<MKMapViewDelegate,UIGestureRecognizerDelegate>
{
    MKMapView *_mapView;
    MKCircle *_radialCircle;
    CLLocation *_location;
    float radiusValue;
    MKPointAnnotation * annotation1;
    
}
@property (nonatomic, strong) NSMutableArray *coordinates;

@end

@implementation KPPolygonVC
@synthesize dictGeofenceInfo,isfromEdit;
- (NSMutableArray*)coordinates
{
    if(_coordinates == nil) _coordinates = [[NSMutableArray alloc] init];
    return _coordinates;
}

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
//    if (isfromEdit)
//    {
//        globalLatitude = [[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"lat"]] doubleValue];
//        globalLongitude = [[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"long"]] doubleValue];
//    }
//    _location = [[CLLocation alloc] initWithLatitude:globalLatitude longitude:globalLongitude];
//    [self setupLocation:_location];
}
-(void)setUpNavigatonView
{
    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, 64)];
    [viewHeader setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:viewHeader];
    
    UILabel *lblBack = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, DEVICE_WIDTH, 44)];
    lblBack.backgroundColor = UIColor.blackColor;
    [viewHeader addSubview:lblBack];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, DEVICE_WIDTH-100, 44)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Add GeoFence"];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setFont:[UIFont fontWithName:CGRegular size:textSize+2]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblTitle];
    
    UIImageView * imgBack = [[UIImageView alloc]initWithFrame:CGRectMake(10,20+11, 14, 22)];
    imgBack.image = [UIImage imageNamed:@"back_icon.png"];
    imgBack.backgroundColor = UIColor.clearColor;
    [viewHeader addSubview:imgBack];
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, 0, 80, 64)];
    [btnBack addTarget:self action:@selector(btnBackClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnBack];
    
    UILabel * lblSave = [[UILabel alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-80, 20, 80, 44)];
    [lblSave setBackgroundColor:[UIColor clearColor]];
    [lblSave setText:@"Save"];
    [lblSave setTextAlignment:NSTextAlignmentCenter];
    [lblSave setFont:[UIFont fontWithName:CGRegular size:textSize]];
    [lblSave setTextColor:[UIColor whiteColor]];
    [viewHeader addSubview:lblSave];
    
    UIButton * btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSave setFrame:CGRectMake(DEVICE_WIDTH-100, 0, 80, 64)];
    //    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont fontWithName:CGRegular size:textSize+1];
    [btnSave addTarget:self action:@selector(btnSaveClick) forControlEvents:UIControlEventTouchUpInside];
    [viewHeader addSubview:btnSave];
    
    if (isfromEdit)
    {
        if (![[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"name"]] isEqualToString:@"NA"])
        {
            [lblTitle setText:[dictGeofenceInfo valueForKey:@"name"]];
        }
    }
    
}
-(void)setUpMapView
{
    int yy = 64;
    if (IS_IPHONE_X) {
        yy = 84;
    }
    searchBar = [[UISearchBar alloc]init];
    searchBar.delegate = self;
    searchBar.frame = CGRectMake(0, yy, self.view.frame.size.width, 50);
    [self.view addSubview:searchBar];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, yy+50, DEVICE_WIDTH, DEVICE_HEIGHT-yy-50)];
    _mapView.showsUserLocation = NO;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    radiusValue = 100;
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    longPressRecognizer.minimumPressDuration = 2.0;
    longPressRecognizer.delegate = self;
    [_mapView addGestureRecognizer:longPressRecognizer];

}
-(void)onLongPress:(UILongPressGestureRecognizer *)pGesture
{
    if (pGesture.state == UIGestureRecognizerStateRecognized)
    {
        //Do something to tell the user!
    }
    if (pGesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint location = [pGesture locationInView:_mapView];
        CLLocationCoordinate2D coordinate = [_mapView convertPoint:location toCoordinateFromView:_mapView];
        [self.coordinates addObject:[NSValue valueWithMKCoordinate:coordinate]];

        MKPointAnnotation *  annotation12 = [[MKPointAnnotation alloc] init];
        annotation12.coordinate = coordinate;
        annotation12.title = [NSString stringWithFormat:@"%lu",self.coordinates.count+1];
        [_mapView addAnnotation:annotation12];

    }
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
    
}
#pragma mark - Search Bar Delegates
-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    
    NSString *address = [NSString stringWithFormat:@"%@",theSearchBar.text];
    
    CLGeocoder * geocoder = [[CLGeocoder alloc]init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(!error)
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSLog(@"%f",placemark.location.coordinate.latitude);
             NSLog(@"%f",placemark.location.coordinate.longitude);
             NSLog(@"%@",[NSString stringWithFormat:@"%@",[placemark description]]);
             
             self->changedLat = placemark.location.coordinate.latitude;
             self->changedLong = placemark.location.coordinate.longitude;
             self->_location = [[CLLocation alloc] initWithLatitude:self->changedLat longitude:self->changedLong];
             [self setupLocation:self->_location];
             
             
             CLLocationCoordinate2D destCoords = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);
             [self->_mapView removeAnnotation:self->annotation2];
             self->annotation2 = [[MKPointAnnotation alloc] init];
             self->annotation2.coordinate = destCoords;
             self->annotation2.title = @"Searched Location";
             [self->_mapView addAnnotation:self->annotation2];
             
         }
         else
         {
             NSLog(@"Error,not able to fetch",[error localizedDescription]);
         }
     }
     ];}
#pragma mark - MapView Delegate
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSInteger numberOfPoints = [self.coordinates count];

    if([self.coordinates count]>2)
    {
        CLLocationCoordinate2D points[numberOfPoints];
        for (NSInteger i = 0; i < numberOfPoints; i++)
        {
            points[i] = [self.coordinates[i] MKCoordinateValue];
        }
        [_mapView addOverlay:[MKPolygon polygonWithCoordinates:points count:numberOfPoints]];

    }
}
- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation
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
   
    pin.animatesDrop = YES;
    pin.draggable = YES;
    pin.canShowCallout = true;
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if(newState == MKAnnotationViewDragStateStarting)
    {
        [_mapView removeOverlay:_radialCircle];
        //        _gotCurrentLocation = NO;
    }
    else if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        _location = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
        _radialCircle = [MKCircle circleWithCenterCoordinate:_location.coordinate radius:radiusValue];
        [_mapView addOverlay:_radialCircle];
        [self changeRadius:radiusValue];
        
//        [_mapView removeAnnotations:_mapView.annotations];
//        annotation1 = [[MKPointAnnotation alloc] init];
//        annotation1.coordinate = annotationView.annotation.coordinate;
//        annotation1.title = @"My current Location";
//        [mapView addAnnotation:annotation1];

        int kk = [annotationView.annotation.title intValue]-1;
        
        NSInteger numberOfPoints = [self.coordinates count];
        
        [_mapView removeOverlays:self.coordinates];
        [self.coordinates replaceObjectAtIndex:kk withObject:[NSValue valueWithMKCoordinate:droppedAt]];
        if([self.coordinates count]>2)
        {
            CLLocationCoordinate2D points[numberOfPoints];
            for (NSInteger i = 0; i < numberOfPoints; i++)
            {
                points[i] = [self.coordinates[i] MKCoordinateValue];
            }
            [_mapView addOverlay:[MKPolygon polygonWithCoordinates:points count:numberOfPoints]];
            
        }
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        self->changedLat = droppedAt.latitude;
        self->changedLong = droppedAt.longitude;
    }
}

//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
//    MKCircleRenderer * renderer = [[MKCircleRenderer alloc] initWithCircle:_radialCircle];
//    renderer.strokeColor = [UIColor blackColor];
//    renderer.fillColor = [UIColor redColor];
//    renderer.alpha = .5f;
//    renderer.lineWidth = 1;
//    return renderer;
//}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKOverlayPathView *overlayPathView;
    
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        overlayPathView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay];
        
        overlayPathView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        overlayPathView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        overlayPathView.lineWidth = 3;
        
        return overlayPathView;
    }
    return nil;
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
}
#pragma mark - All Button Click Events
-(void)btnBackClick
{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)btnSaveClick
{
    NSString * requestStr =[NSString stringWithFormat:@"insert into 'Geofence'('name','radius','type','is_active','lat','long')values(\"%@\",\"%@\",\"%@\",'1',\"%f\",\"%f\")",[dictGeofenceInfo objectForKey:@"name"],[dictGeofenceInfo objectForKey:@"radius"],[dictGeofenceInfo objectForKey:@"type"],self->changedLat,self->changedLong];
    [[DataBaseManager dataBaseManager]execute:requestStr];
    
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    
}
#pragma mark - Geofence Actions
- (IBAction)changeRadius:(float)slider
{
    //    if (!_viewAppeared)
    //    {
    //        return;
    //    }
    //
    NSOperationQueue *currentQueue = [NSOperationQueue new];
    __block MKCircle *radialCircle = nil;
    
    NSOperation *createOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            radialCircle = [MKCircle circleWithCenterCoordinate:_location.coordinate radius:slider];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
