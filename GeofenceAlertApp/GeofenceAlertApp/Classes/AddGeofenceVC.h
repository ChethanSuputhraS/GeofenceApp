//
//  AddGeofenceVC.h
//  GeofenceAlertApp
//
//  Created by srivatsa s pobbathi on 13/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFloatLabelTextField.h"

@interface AddGeofenceVC : UIViewController<UITextFieldDelegate>
{
    UIFloatLabelTextField *txtName,*txtRadius;
    UILabel *lblNameLine,*lblRadiusLine;
    UIImageView *imgRadioCircular,*imgRadioPolygon;
    UIButton *btnNext;
    BOOL isPolygonClicked;
    NSMutableDictionary * dictGeofenceInfo;
}
@property(nonatomic,strong)NSMutableArray *arrGeofence;
@property (assign) BOOL isFromEdit;
@property(nonatomic,strong)NSMutableDictionary *dictEditGeofence;

@end
