//
//  CanvasView.h
//  MapKitDrawing
//
//  Created by tazi afafe on 17/05/2014.
//  Copyright (c) 2014 tazi.omar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PolygonGeofenceVC.h"

@interface CanvasView : UIImageView

@property(nonatomic, weak) PolygonGeofenceVC *delegate;

@end
