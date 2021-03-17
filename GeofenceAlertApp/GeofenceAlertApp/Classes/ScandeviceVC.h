//
//  ScandeviceVC.h
//  GeofenceAlertApp
//
//  Created by Ashwin on 7/16/20.
//  Copyright © 2020 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMPullToRefreshManager.h"
#import "BLEManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScandeviceVC : UIViewController
{
    UITableView * tblDevice;
    MNMPullToRefreshManager * topPullToRefreshManager;

}


@end

NS_ASSUME_NONNULL_END
