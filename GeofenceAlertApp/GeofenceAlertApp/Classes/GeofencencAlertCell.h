//
//  GeofencencAlertCell.h
//  GeofenceAlertApp
//
//  Created by Ashwin on 7/16/20.
//  Copyright © 2020 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GeofencencAlertCell : UITableViewCell
{
    
}
@property(nonatomic,strong)UIImageView * imgArrow;
@property(nonatomic,strong)UILabel * lblDate;
@property(nonatomic,strong)UILabel * lblGeoFncID;
@property(nonatomic,strong)UILabel * lblType;
@property(nonatomic,strong)UILabel * lblStateOfVoi;
@property(nonatomic,strong)UILabel * lblNote;
@property(nonatomic,strong)UILabel * lblCellBgColor;
@property(nonatomic,strong)UILabel * lblForSetting;

@end

NS_ASSUME_NONNULL_END
