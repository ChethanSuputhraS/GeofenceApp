//
//  LiveTrackingVC.h
//  GeofenceAlertApp
//
//  Created by srivatsa s pobbathi on 12/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LiveTrackingVC : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate,UISearchBarDelegate>
{
    CLLocationManager*locationManager;
     MKMapView*mapView;
    float currentLatitude;
    float currentLongitude;
    UISearchBar *searchBar;
    CLLocationCoordinate2D sourceCoords;
    MKPointAnnotation *annotation1,*annotation2;
}
@end
