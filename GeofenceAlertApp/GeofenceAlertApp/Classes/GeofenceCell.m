//
//  GeofenceCell.m
//  GeofenceAlertApp
//
//  Created by srivatsa s pobbathi on 13/06/19.
//  Copyright © 2019 srivatsa s pobbathi. All rights reserved.
//

#import "GeofenceCell.h"

@implementation GeofenceCell
@synthesize lblDeviceName,imgArrow,lblShape,lblBack,lblType;

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
        
        self.backgroundColor = [UIColor clearColor];
        
        lblBack = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,DEVICE_WIDTH-20,60)];
        lblBack.backgroundColor = [UIColor blackColor];
        lblBack.alpha = 0.7;
        lblBack.layer.cornerRadius = 10;
        lblBack.layer.masksToBounds = YES;
        lblBack.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:lblBack];
        
        lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, DEVICE_WIDTH-36, 35)];
        lblDeviceName.numberOfLines = 2;
        [lblDeviceName setBackgroundColor:[UIColor clearColor]];
        lblDeviceName.textColor = UIColor.whiteColor;
        [lblDeviceName setFont:[UIFont fontWithName:CGRegular size:textSize+3]];
        [lblDeviceName setTextAlignment:NSTextAlignmentLeft];
        lblDeviceName.text = @"Geofence 1";
        
        lblType = [[UILabel alloc] initWithFrame:CGRectMake(18, 30, 50, 25)];
        lblType.numberOfLines = 2;
        [lblType setBackgroundColor:[UIColor clearColor]];
        [lblType setTextColor:[UIColor lightGrayColor]];
        [lblType setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [lblType setTextAlignment:NSTextAlignmentLeft];
        lblType.text = @"Type :";
        
        lblShape = [[UILabel alloc] initWithFrame:CGRectMake(18+50, 30, 150, 25)];
        lblShape.numberOfLines = 2;
        [lblShape setBackgroundColor:[UIColor clearColor]];
        [lblShape setTextColor:[UIColor whiteColor]];
        [lblShape setFont:[UIFont fontWithName:CGRegular size:textSize]];
        [lblShape setTextAlignment:NSTextAlignmentLeft];
        lblShape.text = @"Circular";
        
        imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH-35, 20, 12, 20)];
        [imgArrow setImage:[UIImage imageNamed:@"right_icon.png"]];
        [imgArrow setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgArrow];
        
        [self.contentView addSubview:lblDeviceName];
        [self.contentView addSubview:lblShape];
        [self.contentView addSubview:lblType];
    }
    return self;
}
@end
