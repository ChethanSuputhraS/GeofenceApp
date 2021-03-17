//
//  GeofenceVC.h
//  GeofenceAlertApp
//
//  Created by srivatsa s pobbathi on 13/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeofenceVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *tblContent;
    NSMutableArray*arrGeofence;
    int indexGeofence;
}
@end
