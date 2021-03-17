//
//  RadialGeofenceVC.h
//  GeofenceAlertApp
//
//  Created by Kalpesh Panchasara on 26/07/20.
//  Copyright © 2020 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKMapView+ZoomLevel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RadialGeofenceVC : UIViewController
{
    float latValue;
    float longValue;
    MKPointAnnotation *annotation2;
//    float changedLat;
//    float changedLong;
}
@property(nonatomic,strong)NSMutableDictionary * dictGeofenceInfo;
@property BOOL isfromEdit;
@property BOOL isfromHistory;
@end
NS_ASSUME_NONNULL_END
