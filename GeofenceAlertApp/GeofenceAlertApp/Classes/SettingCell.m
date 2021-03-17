//
//  SettingCell.m
//  GeofenceAlertApp
//
//  Created by Ashwin on 8/31/20.
//  Copyright © 2020 srivatsa s pobbathi. All rights reserved.
//

#import "SettingCell.h"

@implementation SettingCell
@synthesize lblForSetting,lblSetValue,imgArrow,lblBack;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {    // Initialization code
      
      
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,DEVICE_WIDTH-0,50)];
        lblBack.backgroundColor = [UIColor blackColor];
        lblBack.alpha = 0.7;
        lblBack.layer.cornerRadius = 10;
        lblBack.layer.masksToBounds = YES;
        lblBack.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:lblBack];
        
        lblForSetting = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH-20, 50)];
        lblForSetting.numberOfLines = 0;
        [lblForSetting setBackgroundColor:[UIColor clearColor]];
        [lblForSetting setTextColor:[UIColor whiteColor]];
        [lblForSetting setFont:[UIFont fontWithName:CGRegular size:textSize -1 ]];
        [lblForSetting setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:lblForSetting];
        
        lblSetValue = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, DEVICE_WIDTH-30, 50)];
        lblSetValue.numberOfLines = 0;
        [lblSetValue setBackgroundColor:[UIColor clearColor]];
        [lblSetValue setTextColor:[UIColor whiteColor]];
        [lblSetValue setFont:[UIFont fontWithName:CGRegular size:textSize -1 ]];
        [lblSetValue setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:lblSetValue];
        
        
        imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-12, 20, 10, 12)];
        [imgArrow setImage:[UIImage imageNamed:@"right_icon.png"]];
        [imgArrow setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgArrow];
          
            }
            return self;
        }
        
@end
