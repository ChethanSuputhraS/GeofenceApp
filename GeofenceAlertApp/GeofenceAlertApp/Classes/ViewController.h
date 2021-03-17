//
//  ViewController.h
//  GeofenceAlertApp
//
//  Created by srivatsa s pobbathi on 06/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"

@interface ViewController : UIViewController<UISearchBarDelegate>
{
    float latValue;
    float longValue;
    MKPointAnnotation *annotation2;
    float changedLat;
    float changedLong;
}
@property(nonatomic,strong)NSMutableDictionary * dictGeofenceInfo;
@property(nonatomic,strong)NSMutableArray *dictGpsData;
@property BOOL isfromEdit;
@end

