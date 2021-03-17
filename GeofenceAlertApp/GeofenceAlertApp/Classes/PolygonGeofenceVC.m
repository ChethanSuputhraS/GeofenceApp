//
//  PolygonGeofenceVC.m
//  GeofenceAlertApp
//
//  Created by stuart watts on 08/06/2019.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "PolygonGeofenceVC.h"
#import <MapKit/MapKit.h>
#import "CanvasView.h"

#import "CustomAnnotation.h"
#import "CustomAnnotationView.h"

#define span1 5000 // 5000

@interface PolygonGeofenceVC ()<MKMapViewDelegate>
{
    MKMapView *_mapView;
    MKPolygon * polV;
    CLLocationCoordinate2D * myLocations;
    MKPointAnnotation * annotation1;
    BOOL isEditModified;
    double breachLat, breachLong;
    NSMutableArray * arrTotal;

    
    CustomAnnotation * annotationPin;
    CustomAnnotationView* custannotationView;
    NSString * strScreenMode;


}
@property (nonatomic, strong) CanvasView *canvasView;
@property (nonatomic, strong) NSMutableArray *coordinates;
@property (nonatomic, strong) NSMutableArray *polygonPoints;
@property (nonatomic) BOOL isDrawingPolygon;

@end

@implementation PolygonGeofenceVC
@synthesize canvasView = _canvasView;
@synthesize coordinates = _coordinates;
@synthesize dictGeofenceInfo;
@synthesize isfromEdit;
- (NSMutableArray*)coordinates
{
    if(_coordinates == nil) _coordinates = [[NSMutableArray alloc] init];
    return _coordinates;
}
- (CanvasView*)canvasView
{
    if(_canvasView == nil) {
        _canvasView = [[CanvasView alloc] initWithFrame:self->_mapView.frame];
        _canvasView.userInteractionEnabled = YES;
        _canvasView.delegate = self;
    }
    return _canvasView;
}

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
    NSLog(@"-------------->Mode------->%@",strScreenMode);
    self.navigationController.navigationBarHidden = true;
    
    breachLat = globalLatitude;
    breachLong = globalLongitude;

    if (![[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"Breach_Lat"]] isEqualToString:@"NA"])
    {
        breachLat = [[dictGeofenceInfo valueForKey:@"Breach_Lat"] floatValue];
        breachLong = [[dictGeofenceInfo valueForKey:@"Breach_Long"] floatValue];
    }

    NSString * strQuery = [NSString stringWithFormat:@"select * from Geofence where geofence_ID = '%@'",[dictGeofenceInfo valueForKey:@"geofence_ID"]];//kalpesh Change Geofence_ID to geofence_ID
    NSMutableArray * dataArr = [[NSMutableArray alloc] init];
    [[DataBaseManager dataBaseManager] execute:strQuery resultsArray:dataArr];

    [self setUpNavigatonView];
    [self setUpMapView];
    
// [dictGeofenceInfo setValue:[dictGeofenceInfo valueForKey:@"Violated_ID"] forKey:@"BreachRule_ID"];//Commen this line as Violated_ID is BreachRule_ID....
// [dictGeofenceInfo setValue:[dictGeofenceInfo valueForKey:@"Value"] forKey:@"BreachRuleValue"];//Commen this line as Violated_ID is BreachRule_ID....

    [super viewDidLoad];
    // Do any additional setup after loading the view.

}
-(void)setUpNavigatonView
{
    int yy = 44;
    if (IS_IPHONE_X)
    {
        yy = 44;
    }

    UIView * viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, yy + globalStatusHeight)];
    [viewHeader setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewHeader];
    
    UILabel * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, globalStatusHeight, DEVICE_WIDTH-100, yy)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setText:@"Geofence Location"];
//    lblTitle.text = [NSString stringWithFormat:@"Polygon ID: %@",[dictGeofenceInfo valueForKey:@"geofence_ID"]];
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
}
-(void)setUpMapView
{
    int yy = 64;
    if (IS_IPHONE_X)
    {
        yy = 84;
    }


    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, yy, DEVICE_WIDTH, DEVICE_HEIGHT-yy)];
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    CLLocation  * currentLocation= [[CLLocation alloc] initWithLatitude:breachLat longitude:breachLat];
//        CLLocationCoordinate2D location=CLLocationCoordinate2DMake(breachLat, breachLat);
//        MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(location,span1 ,span1);
//        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:region];
//        [_mapView setRegion:adjustedRegion animated:YES];

    [_mapView removeAnnotations:_mapView.annotations];
    annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = currentLocation.coordinate;
    annotation1.title = @"SC2 Device Current Location";
    [_mapView addAnnotation:annotation1];
    if (![[APP_DELEGATE checkforValidString:[dictGeofenceInfo valueForKey:@"bleAddress"]] isEqualToString:@"NA"])
    {
        annotation1.title = [NSString stringWithFormat:@"%@'s location",[dictGeofenceInfo valueForKey:@"bleAddress"]];
    }

    if (isfromEdit)
    {
        NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
        NSString * strQury = [NSString stringWithFormat:@"select * from Polygon_Lat_Long where geofence_ID ='%@'",[dictGeofenceInfo valueForKey:@"geofence_ID"]];
        [[DataBaseManager dataBaseManager] execute:strQury resultsArray:tmpArr];
        
//        NSArray * latArr = [NSArray arrayWithObjects:@"12.462912",@"12.277798",@"12.036149",@"12.224117",@"12.513862", nil];
//        NSArray * lonArr = [NSArray arrayWithObjects:@"76.537297",@"76.413701",@"76.633427",@"76.902592",@"76.831181", nil];

        //    12.462912,76.537297
        //    12.277798,76.413701
        //    12.036149,76.633427
        //    12.224117,76.902592
        //    12.513862,76.831181

        for (int i =0; i<[tmpArr count]; i++)
        {
            double flat = [[[tmpArr objectAtIndex:i] valueForKey:@"lat"] doubleValue];
            double flong = [[[tmpArr objectAtIndex:i] valueForKey:@"long"] doubleValue];
            CLLocationCoordinate2D location=CLLocationCoordinate2DMake(flat,flong);
            [self.coordinates addObject:[NSValue valueWithMKCoordinate:location]];
        }
        
        NSInteger numberOfPoints = [self.coordinates count];
        if (numberOfPoints > 2)
        {
            CLLocationCoordinate2D points[numberOfPoints];
            for (NSInteger i = 0; i < numberOfPoints; i++)
            {
                points[i] = [self.coordinates[i] MKCoordinateValue];
            }
            MKPolygon * polygon = [MKPolygon polygonWithCoordinates:points count:numberOfPoints];
            [_mapView addOverlay:polygon];
        }
        self.isDrawingPolygon = NO;
        self.canvasView.image = nil;
        [self.canvasView removeFromSuperview];
        
    }
}


#pragma mark - MKMapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKOverlayPathView *overlayPathView;
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        UIColor * overlayColor = [UIColor blackColor];
        if ([strScreenMode isEqualToString:@"Dark"])
        {
            overlayColor = [UIColor blueColor];
        }
        overlayPathView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay];
        overlayPathView.fillColor = [overlayColor colorWithAlphaComponent:0.5];
        overlayPathView.strokeColor = [overlayColor colorWithAlphaComponent:0.7];
        overlayPathView.lineWidth = 3;
        return overlayPathView;
    }
    return nil;
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
            ([mp coordinate], 500, 500);
            if (region.center.latitude > -89 && region.center.latitude < 89 && region.center.longitude > -179 && region.center.longitude < 179 )
            {
                [mv setRegion:region animated:YES];
                [mv selectAnnotation:mp animated:YES];
            }
        }
    }
}

#pragma mark - All Button Clicks
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
-(void)getDistances
{
    arrTotal= [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [self.coordinates count]; i++)
    {
        NSValue *coordinateValue = self.coordinates[i];
        CLLocationCoordinate2D coordinate = [coordinateValue MKCoordinateValue];
        
        [self DetectWhetherPointinGefoencewith:coordinate.latitude withLong:coordinate.longitude];
    }
}
-(void)DetectWhetherPointinGefoencewith:(double)latitude withLong:(double)longitude
{
    NSValue *coordinateValue = self.coordinates[0];
    CLLocationCoordinate2D coordinate = [coordinateValue MKCoordinateValue];

    double lat2 = coordinate.latitude;
    double lon2 = coordinate.longitude;
    double lat1 = latitude;
    double lon1 = longitude;
    
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:lat2 longitude:lon2];
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    
    NSInteger valuess = distance;
    [arrTotal addObject:[NSNumber numberWithInteger:valuess]];
    
//    12.462912,76.537297
//    12.277798,76.413701
//    12.036149,76.633427
//    12.224117,76.902592
//    12.513862,76.831181
//
}
/*- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if(newState == MKAnnotationViewDragStateStarting)
    {
    }
    else if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        
        [_mapView removeAnnotations:_mapView.annotations];
        annotation1 = [[MKPointAnnotation alloc] init];
        annotation1.coordinate = annotationView.annotation.coordinate;
        annotation1.title = @"My current Location";
        [mapView addAnnotation:annotation1];
        
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        float changedLat = droppedAt.latitude;;
        float changedLong = droppedAt.longitude;
        [self checkIfLocIsInsideGeofence:changedLat :changedLong];
    }
}*/
-(void)checkIfLocIsInsideGeofence:(double)latitude :(double)logitude
{
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    NSString * strQury = [NSString stringWithFormat:@"select * from Geofence_Polygon where geofence_ID ='%@'",[dictGeofenceInfo valueForKey:@"geofence_ID"]];
    [[DataBaseManager dataBaseManager] execute:strQury resultsArray:tmpArr];
    NSMutableArray * polyCorners = [[NSMutableArray alloc]init];
    polyCorners = tmpArr;

    
    int nvert = [tmpArr count];
    float vertx, verty,  testx, testy, vertJx, vertJy;
    testx = latitude;
    testy = logitude;
        int i, j, c = 0;
        for (i = 0, j = nvert-1; i < nvert; j = i++)
        {
            vertx = [[[polyCorners objectAtIndex:i] valueForKey:@"lat"] floatValue];
            verty =  [[[polyCorners objectAtIndex:i] valueForKey:@"long"] floatValue];
            
            vertJx = [[[polyCorners objectAtIndex:j] valueForKey:@"lat"] floatValue];
            vertJy =  [[[polyCorners objectAtIndex:j] valueForKey:@"long"] floatValue];


            if ( ((verty>testy) != (vertJy>testy)) &&
                (testx < (vertJx-vertx) * (testy-verty) / (vertJy-verty) + vertx) )
                c = !c;
        }
    NSLog(@"THIS IS OUTCOME=%d",c);
//        return c;
}

/*-(void)checkIfLocIsInsideGeofence:(double)latitude :(double)logitude
{

    ///////////////////////////              sri      //////////////////////
    NSMutableArray * tmpArr = [[NSMutableArray alloc] init];
    NSString * strQury = [NSString stringWithFormat:@"select * from Geofence_Polygon where geofence_ID ='%@'",[dictGeofenceInfo valueForKey:@"id"]];
    [[DataBaseManager dataBaseManager] execute:strQury resultsArray:tmpArr];
    NSMutableArray * polyCorners = [[NSMutableArray alloc]init];
    polyCorners = tmpArr;
    bool isPointInPolygon;
    {
        int i;
        long j=polyCorners.count-1 ;
        double polyY,polyX;
//        bool  isOddNodes;
        double x = latitude;
        double y = logitude;
        for (i=0; i<polyCorners.count; i++)
        {
            double polyJX = [[[polyCorners objectAtIndex:j] valueForKey:@"lat"] floatValue];
            double polyJY =  [[[polyCorners objectAtIndex:j] valueForKey:@"long"] floatValue];

            polyX = [[[polyCorners objectAtIndex:i] valueForKey:@"lat"] floatValue];
            polyY = [[[polyCorners objectAtIndex:i] valueForKey:@"long"] floatValue];
            
            if ((polyY<y && polyJY>=y) ||  (polyJY<y && polyY>=y))
            {
                if (polyX+(y-polyY)/(polyJY-polyY)*(polyJX-polyX)<x)
                {
                    isPointInPolygon= true;
                    NSLog(@"point is inside geofence");
                }
                else
                {
//                    NSLog(@"point is outside geofence");
                }
            }
             j = i;
        }
    }
    ///////////////////////////              sri      //////////////////////
}*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
