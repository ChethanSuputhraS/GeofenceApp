//
//  LeftMenuCell.h
//  SC4App18
//
//  Created by stuart watts on 17/04/2018.
//  Copyright © 2018 Kalpesh Panchasara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftMenuCell : UITableViewCell

@property(nonatomic,strong) UILabel * lblBack;
@property(nonatomic,strong) UIImageView * imgArrow;
@property(nonatomic,strong) UIImageView * imgIcon;
@property(nonatomic,strong) UILabel * lblName;
@property(nonatomic,strong) UILabel * lblLine;
@property(nonatomic,strong) UILabel * lblContact;
@property(nonatomic,strong) UILabel * lblNanoID;
@property(nonatomic,strong) UILabel * lblIrridiumID;
@property(nonatomic,strong) UILabel * lblBiometrics;
@property(nonatomic,strong) UILabel * lblBleAdd;
@property(nonatomic,strong) UILabel * lblGSMIrridiumID;
@property(nonatomic,strong) UILabel * lblRight;
@property(nonatomic, strong) UISwitch * wifiSwitch;
@end
