//
//  PolygonGeofenceVC.h
//  GeofenceAlertApp
//
//  Created by stuart watts on 08/06/2019.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PolygonGeofenceVC : UIViewController<UISearchBarDelegate>
{

}
- (void)touchesBegan:(UITouch*)touch;
- (void)touchesMoved:(UITouch*)touch;
- (void)touchesEnded:(UITouch*)touch;

@property(nonatomic,strong)NSMutableDictionary * dictGeofenceInfo;
@property BOOL isfromEdit;
@property BOOL isfromHistory;

@end

NS_ASSUME_NONNULL_END
