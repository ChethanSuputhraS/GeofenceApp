//
//  KPPolygonVC.h
//  GeofenceAlertApp
//
//  Created by stuart watts on 17/06/2019.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KPPolygonVC : UIViewController<UISearchBarDelegate>
{
    float latValue;
    float longValue;
    UISearchBar *searchBar;
    MKPointAnnotation *annotation2;
    float changedLat;
    float changedLong;
}
@property(nonatomic,strong)NSMutableDictionary * dictGeofenceInfo;
@property(nonatomic,strong)NSMutableArray *dictGpsData;
@property BOOL isfromEdit;

@end

NS_ASSUME_NONNULL_END
